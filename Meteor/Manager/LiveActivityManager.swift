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
    
    var currentActivity: Activity<MeteorAttributes>?
    var already = true
    
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
                
//                try await Task.sleep(for: .seconds(0.3))
                guard let liveText = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) else { return }
                startActivity(text: liveText)
            } else {
                await endAlwaysActivity()
                
//                try await Task.sleep(for: .seconds(0.3))
                startAlwaysActivity()
            }
//            try await Task.sleep(for: .seconds(0.5))
//            loadActivity()
        }
    }
    
    @discardableResult
    func startActivity(text: String) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
        
        Task {
            await endAlwaysActivity()
            
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.timeZone = TimeZone(abbreviation: "KST")
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let date = formatter.string(from: Date())
            print(date)
            
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
//            await observeAlwaysActivity(activity: activity)
        }
    }
    
    private func observeActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🌈🌈🌈🌈🌈🌈🌈")
                    print(activity.id)
                    self.already = false
                    if activityState == .dismissed {
//                        MeteorViewModel().sendSingleMeteor(text: "디스미스")
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) == false {
                            // isActivityAlive 함수 체크용
                            self.currentActivity = nil
                        }

                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) {
                            do {
                                try await Task.sleep(for: .seconds(1))
                                if !self.isActivityAlive() && self.currentActivity != nil && self.already == false {
//                                    MeteorViewModel().sendSingleMeteor(text: "옵저브 디스미스 푸시불림")
                                    await self.push(liveText: "")
                                    self.loadActivity()
                                    self.already = true
                                }
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        
                    } else if activityState == .ended {
//                        MeteorViewModel().sendSingleMeteor(text: "옵저브 엔드")
                        
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) {
                            await self.endActivity()
                            
//                            if !self.isActivityAlive() {
//                                MeteorViewModel().sendSingleMeteor(text: "옵저브 엔드 푸시불림")
                                await self.push(liveText: UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? "")
                                self.loadActivity()
//                            }
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
                        print(activity.id)
                        
//                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
//                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey),// {
//                           !self.isActivityAlive() {
//                            await self.push(liveText: "")
//                            self.loadActivity()
//                        }
                        
                    } else if activityState == .ended {
//                        MeteorViewModel().sendSingleMeteor(text: "올웨이즈 옵저브 엔드")
                        
                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
                           UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey),// {
                           self.isActivityAlive() {
                            await self.endActivity()
                            
//                            if !self.isActivityAlive() {
//                                MeteorViewModel().sendSingleMeteor(text: "올웨이즈 옵저브 엔드 푸시불림")
                                await self.push(liveText: "")
                                self.loadActivity()
//                            }
                        }
                    }
                }
            }
        }
    }
    
    func endActivity() async {
        guard let activity = currentActivity else { return }
        currentActivity = nil
        
//        Task {
            let (_, finalContent) = activityTemplete(liveText: "none")
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
//            startAlwaysActivity()
//        }
    }
    
    func endAlwaysActivity() async {
        let activities = Activity<MeteorAttributes>.activities
            .filter({ $0.content.state.liveText == "" })
            
//        Task {
        for activity in activities {
            let (_, finalContent) = activityTemplete(liveText: "none")
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
//        }
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
    
//    /// Live 타임아웃 때 전송될 Local notification 등록
//    private func registerLocalNotificaiton(text: String) async {
//        print("👀 live noti start")
//        
//        let contents = UNMutableNotificationContent()
//        contents.title = NSLocalizedString("⚠️ Live Expired", comment: "")
//        contents.body = text
//        contents.sound = .default
//        let twelveHours: TimeInterval = 12 * 60 * 60
//        
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//        let request = UNNotificationRequest(identifier: "live", content: contents, trigger: trigger)
//        
//        do {
//            try await UNUserNotificationCenter.current().add(request)
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//    
//    /// Local notification 해제
//    private func removeLocalNotificaiton() {
//        print("⚠️ live pending remove")
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["live"])
//    }
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
        
        guard let p8Payload = FileParser.parse() else { return }
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
