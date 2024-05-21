//
//  LiveActivityManager.swift
//  Meteor
//
//  Created by 장기화 on 4/19/24.
//

import UserNotifications
import ActivityKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    /// isActivityAlive() 체크용
    var currentActivity: Activity<MeteorAttributes>?
    
    func loadActivity() {
        let activityList = Activity<MeteorAttributes>.activities
        
        Task {
            if let activity = activityList.filter({ $0.content.state.liveText != "" }).first {
                currentActivity = activity
                await observeActivity(activity: activity)
            } else if let activity = activityList.filter({ $0.content.state.liveText == "" }).first {
                currentActivity = nil
                await observeAlwaysActivity(activity: activity)
            } else {
                currentActivity = nil
            }
        }
    }
    
    func rebootActivity() {
        Task {
            if currentActivity != nil {
                await endActivity()
                guard let liveText = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) else { return }
                startActivity(text: liveText)
            } else {
                await endAlwaysActivity()
                startAlwaysActivity()
            }
        }
    }
    
    @discardableResult
    func startActivity(text: String) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
        
        Task {
            await endAlwaysActivity()
            
            let (attributes, content) = activityTemplete(liveText: text)
            let activity = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
            currentActivity = activity
            loadActivity()
        }
        return true
    }
    
    func startAlwaysActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
              currentActivity == nil,
              Activity<MeteorAttributes>.activities.isEmpty else { return }
        
        Task {
            let (attributes, content) = activityTemplete(liveText: "")
            let _ = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
            loadActivity()
        }
    }
    
    private func observeActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🌈🌈🌈🌈🌈🌈🌈")
                    print(activity.id)
                    if activityState == .dismissed {
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) == false {
                            self.currentActivity = nil
                        }
                        
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) {
                            do {
                                try await Task.sleep(for: .seconds(1))
                                if !self.isActivityAlive() && self.currentActivity != nil {
                                    await self.push(liveText: "")
                                    self.loadActivity()
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    } else if activityState == .ended {
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) {
                            await self.endActivity()
                            await self.push(liveText: UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? "")
                            self.loadActivity()
                        }
                    }
                }
            }
        }
    }
    
    private func observeAlwaysActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🍓🍓🍓🍓🍓🍓🍓")
                    if activityState == .dismissed {
                        
                    } else if activityState == .ended {
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey),// {
                           self.isActivityAlive() {
                            await self.endActivity()
                            await self.push(liveText: "")
                            self.loadActivity()
                        }
                    }
                }
            }
        }
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        
        let (_, finalContent) = activityTemplete(liveText: "none")
        await activity.end(finalContent, dismissalPolicy: .immediate)
        print("Ending the Live Activity(Timer): \(activity.id)")
    }
    
    func endAlwaysActivity() async {
        let activities = Activity<MeteorAttributes>.activities.filter({ $0.content.state.liveText == "" })
        
        for activity in activities {
            let (_, finalContent) = activityTemplete(liveText: "none")
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
        }
    }
    
    func isActivityAlive() -> Bool {
        if let currentActivity {
            switch currentActivity.activityState {
            case .dismissed:
                return false
            default:
                return true
            }
        } else {
            return false
        }
    }
    
    func isSupportVersion() -> Bool {
        if #available(iOS 17.2, *) {
            return true
        } else {
            return false
        }
    }
    
    private func activityTemplete(liveText: String) -> (MeteorAttributes, ActivityContent<MeteorAttributes.ContentState>) {
        let attributes = MeteorAttributes()
        let state = MeteorAttributes.ContentState(
            liveText: liveText,
            liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
            isContentHide: UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveContentHideStateKey),
            isMinimize: UserDefaults.standard.bool(forKey: UserDefaultsKeys.minimizeDynamicIslandStateKey),
            isAlwaysOnLive: UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey)
        )
        let content = ActivityContent(state: state, staleDate: .distantFuture)
        return (attributes, content)
    }
}

extension LiveActivityManager {
    func getPushToStartToken() {
        if #available(iOS 17.2, *) {
            Task {
                for await data in Activity<MeteorAttributes>.pushToStartTokenUpdates {
                    let token = data.hexadecimalString
                    print("🌊 Activity PushToStart Token: \(token)")
                    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.liveDeviceTokenKey)
                }
            }
        }
    }
    
    func push(liveText: String) async {
        guard Activity<MeteorAttributes>.activities.filter({ $0.content.state.liveText == "" }).isEmpty else { return }
        print("🐤 푸시불림")
        let payload =
"""
{
    "aps": {
        "timestamp": \(Date.timestamp),
        "event": "start",
        "content-state": {
            "liveText": "\(liveText)",
            "liveColor": 4,
            "isContentHide": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveContentHideStateKey)),
            "isMinimize": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.minimizeDynamicIslandStateKey)),
            "isAlwaysOnLive": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey))
        },
        "attributes-type": "MeteorAttributes",
        "attributes": {
            "liveText": "\(liveText)",
            "liveColor": 4,
            "isContentHide": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveContentHideStateKey)),
            "isMinimize": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.minimizeDynamicIslandStateKey)),
            "isAlwaysOnLive": \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey))
        },
        "alert": {
            "title": "Meteor",
            "body": {
                "loc-key": "Live Restarted",
            }
        }
    }
}
"""
        
        guard let p8Payload = FileParser.parse() else { return print("❌ parse 실패") }
        do {
            let jsonWebToken = try JSONWebToken(keyID: FileParser.keyID, teamID: FileParser.teamID, p8Payload: p8Payload)
            let authenticationToken = jsonWebToken.token
            print("🍓 jsonWebToken : \(authenticationToken)")
            let deviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveDeviceTokenKey) ?? ""
            
            guard let request = APNSManager().urlRequest(
                authenticationToken: authenticationToken,
                deviceToken: deviceToken,
                payload: payload) else { return }
            
            let (data, response) = try await URLSession.shared.data(for: request)
            var messages = [String]()
            
            if let description = String(data: data, encoding: .utf8),
               !description.isEmpty {
                messages.append("Payload: \(description)")
            }
            
            if let response = response as? HTTPURLResponse {
                var description = response.description
                let regex = try! NSRegularExpression(pattern: "<.*:.*x.*>", options: NSRegularExpression.Options.caseInsensitive)
                let range = NSMakeRange(0, description.count)
                description = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "Response:")
                if let url = response.url {
                    messages.append("URL: \(url)")
                }
                
                messages.append("Status Code: \(response.statusCode) (\(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))")
                
                if let allHeaderFields = response.allHeaderFields as? [String: String] {
                    messages.append("Header: \(allHeaderFields.description)")
                }
            }
            print("🍖 \(messages.compactMap { $0 }.joined(separator: "\n")) \n-----")
            
        } catch {
            print(error.localizedDescription)
        }
    }
}
