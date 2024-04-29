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
    
    func loadActivity() {
        let activityList = Activity<MeteorAttributes>.activities
        
        Task {
            if let activity = activityList.filter({ $0.content.state.liveText != "" }).first {
                currentActivity = activity
                await observeActivity(activity: activity)
            } else if let activity = activityList.filter({ $0.content.state.liveText == "" }).first {
                currentActivity = nil
                await observeAlwaysActivity(activity: activity)
                removeLocalNotificaiton()
            } else {
                currentActivity = nil
                removeLocalNotificaiton()
            }
        }
    }
    
    @discardableResult
    func startActivity(text: String) -> Bool {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return false }
        UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
        
        Task {
            await registerLocalNotificaiton(text: text)
            await endAlwaysActivity()
            
            let (attributes, content) = activityTemplete(liveText: text)
            let activity = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
            currentActivity = activity
            await observeActivity(activity: activity)
        }
        return true
    }
    
    func startAlwaysActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled,
              UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey),
              currentActivity == nil,
              Activity<MeteorAttributes>.activities.filter({ $0.content.state.liveText != "" }).isEmpty,
              Activity<MeteorAttributes>.activities.filter({ $0.content.state.liveText == "" }).isEmpty else { return }
            
        Task {
            let (attributes, content) = activityTemplete(liveText: "")
            let activity = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
            await observeAlwaysActivity(activity: activity)
        }
    }
    
    private func observeActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
//            guard let activity = Activity<MeteorWidgetAttributes>.activities.first else { return }
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🌈🌈🌈🌈🌈🌈🌈")
                    print(activity.id)
                    if activityState == .dismissed {
//                        self.endLiveActivity()
                        self.currentActivity = nil
                        self.removeLocalNotificaiton()
//                        self.betaStart(liveText: "")
                        
//                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveKey) {
//                            await self.push(timestamp: Date.timestamp, liveColor: 2, isHide: true)
//                            await self.loadLiveActivity()
//                        }
                    } else if activityState == .ended {
//                        self.betaStart(liveText: UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? "")
                    }
                }
            }
            
//            if #available(iOS 17.2, *) {
//                group.addTask { @MainActor in
//                    for await pushToken in activity.pushTokenUpdates {
//                        let pushTokenString = pushToken.hexadecimalString
//                        print("New push token: \(pushTokenString)")
//                        
//                        UserDefaults.standard.set(pushTokenString, forKey: UserDefaultsKeys.liveDeviceTokenKey)
//                    }
//                }
//            }
        }
    }
    
    private func observeAlwaysActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
//            guard let activity = Activity<MeteorWidgetAttributes>.activities.first else { return }
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🍓🍓🍓🍓🍓🍓🍓")
                    print(activity.id)
                    if activityState == .dismissed {
//                        await self.push(timestamp: Date.timestamp, liveText: "", liveColor: 1, isHide: true)

//                        self.betaStart(liveText: "")
//                        self.endLiveActivity()
//                        self.currentActivity = nil
                        
//                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveKey) {
//                            await self.push(timestamp: Date.timestamp, liveColor: 2, isHide: true)
//                            await self.loadLiveActivity()
//                        }
                    } else if activityState == .ended {
                        await self.endAlwaysActivity()
                        await self.push(timestamp: Date.timestamp, liveText: "hi", liveColor: 0, isHide: true)
                    }
                }
            }
            
//            if #available(iOS 17.2, *) {
//                group.addTask { @MainActor in
//                    for await pushToken in activity.pushTokenUpdates {
//                        let pushTokenString = pushToken.hexadecimalString
//                        print("New push token: \(pushTokenString)")
//
//                        UserDefaults.standard.set(pushTokenString, forKey: UserDefaultsKeys.liveDeviceTokenKey)
//                    }
//                }
//            }
        }
    }
    
    func endActivity() async {
        removeLocalNotificaiton()
        
        guard let activity = currentActivity else { return }
        currentActivity = nil
        
//        Task {
            let (_, finalContent) = activityTemplete(liveText: "none")
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
            startAlwaysActivity()
//        }
    }
    
    func endAlwaysActivity() async {
        guard let activity = Activity<MeteorAttributes>.activities
            .filter({ $0.content.state.liveText == "" })
            .first else { return }
            
//        Task {
            let (_, finalContent) = activityTemplete(liveText: "none")
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
//        }
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
            loadActivity()
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
    
    private func activityTemplete(liveText: String) -> (MeteorAttributes, ActivityContent<MeteorAttributes.ContentState>) {
        let attributes = MeteorAttributes()
        let state = MeteorAttributes.ContentState(
            liveText: liveText,
            liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
            ishide: UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey)
        )
        let content = ActivityContent(state: state, staleDate: .distantFuture)
        return (attributes, content)
    }
    
    /// Live 타임아웃 때 전송될 Local notification 등록
    private func registerLocalNotificaiton(text: String) async {
        print("👀 live noti start")
        
        let contents = UNMutableNotificationContent()
        contents.title = NSLocalizedString("⚠️ Live Expired", comment: "")
        contents.body = text
        contents.sound = .default
        let twelveHours: TimeInterval = 12 * 60 * 60
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "live", content: contents, trigger: trigger)
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    /// Local notification 해제
    private func removeLocalNotificaiton() {
        print("⚠️ live pending remove")
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["live"])
    }
}

extension LiveActivityManager {
    func getPushToStartToken() {
//        Task {
//            rebootLive()
            
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
    
    func betaStart(liveText: String) {
        
        print("여기 찍힘????? \(UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey))")
        
        Task {
            getPushToStartToken()
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveBackgroundUpdateStateKey) {
                if !isActivityAlive() {
                    push(
                        timestamp: Date.timestamp,
                        liveText: liveText,
                        liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
                        isHide: UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey)
                    )
                    //                loadActivity()
                }
            }
//            if Activity<MeteorAttributes>.activities.isEmpty == false {
//                await endLiveActivity()
//            }
//            await push(timestamp: Date.timestamp, liveColor: color, isHide: true)
//            await loadLiveActivity()
        }
    }
    
    func betaStop() {
        guard let activity = Activity<MeteorAttributes>.activities.first else { return }
        
        Task {
            let finalState = MeteorAttributes.ContentState(
                liveText: "none",
                liveColor: 0,
                ishide: false
            )
            let finalContent = ActivityContent(state: finalState, staleDate: nil)
            await activity.end(finalContent, dismissalPolicy: .immediate)
        }
    }
    
    func push(timestamp: Int, liveText: String, liveColor: Int, isHide: Bool) {
        print("🐤🐤🐤 푸시불림")
        guard let p8Payload = FileParser.parse() else { return }
        do {
            let jsonWebToken = try JSONWebToken(keyID: FileParser.keyID, teamID: FileParser.teamID, p8Payload: p8Payload)
            let authenticationToken = jsonWebToken.token
            print("🍓 jsonWebToken : \(authenticationToken)")
            let deviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveDeviceTokenKey) ?? ""
            let payload =
"""
{
    "aps": {
        "timestamp": \(timestamp),
        "event": "start",
        "content-state": {
            "liveText": \(liveText),
            "liveColor": \(liveColor),
            "isHide": \(isHide)
        },
        "attributes-type": "MeteorAttributes",
        "attributes": {
            "liveText": "",
            "liveColor": \(liveColor),
            "isHide": \(isHide)
        },
        "alert": {
            "title": "A",
            "body": "B"
        }
    }
}
"""
            guard let request = APNSManager().urlRequest(
                authenticationToken: authenticationToken,
                deviceToken: deviceToken,
                payload: payload) else { return }
            
            let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
                guard let self else { return }
                
                //            let (data, response) = try await URLSession.shared.data(for: request)
                var messages = [String]()
                
                if let data,
                   let description = String(data: data, encoding: .utf8),
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
            }
            
            task.resume()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
//    func push(timestamp: Int, liveText: String, liveColor: Int, isHide: Bool) async {
//        print("🐤🐤🐤 푸시불림")
//        guard let p8Payload = FileParser.parse() else { return }
//        do {
//            let jsonWebToken = try JSONWebToken(keyID: FileParser.keyID, teamID: FileParser.teamID, p8Payload: p8Payload)
//            let authenticationToken = jsonWebToken.token
//            print("🍓 jsonWebToken : \(authenticationToken)")
//            let deviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveDeviceTokenKey) ?? ""
//            let payload =
//"""
//{
//    "aps": {
//        "timestamp": \(timestamp),
//        "event": "start",
//        "content-state": {
//            "liveText": \(liveText),
//            "liveColor": \(liveColor),
//            "isHide": \(isHide)
//        },
//        "attributes-type": "MeteorAttributes",
//        "attributes": {
//            "liveText": "",
//            "liveColor": \(liveColor),
//            "isHide": \(isHide)
//        },
//        "alert": {
//            "title": "A",
//            "body": "B"
//        }
//    }
//}
//"""
//            guard let request = APNSManager().urlRequest(
//                authenticationToken: authenticationToken,
//                deviceToken: deviceToken,
//                payload: payload) else { return }
//            
//            let (data, response) = try await URLSession.shared.data(for: request)
//            var messages = [String]()
//            
//            if let description = String(data: data, encoding: .utf8),
//               !description.isEmpty {
//                messages.append("Payload: \(description)")
//            }
//            
//            if let response = response as? HTTPURLResponse {
//                var description = response.description
//                let regex = try! NSRegularExpression(pattern: "<.*:.*x.*>", options: NSRegularExpression.Options.caseInsensitive)
//                let range = NSMakeRange(0, description.count)
//                description = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "Response:")
//                if let url = response.url {
//                    messages.append("URL: \(url)")
//                }
//                
//                messages.append("Status Code: \(response.statusCode) (\(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))")
//                
//                if let allHeaderFields = response.allHeaderFields as? [String: String] {
//                    messages.append("Header: \(allHeaderFields.description)")
//                }
//            }
//            print("🍖 \(messages.compactMap { $0 }.joined(separator: "\n")) \n-----")
//            
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
}

//class LiveActivityManager {
//    static let shared = LiveActivityManager()
//    
//    func getPushToStartToken() {
//        if #available(iOS 17.2, *) {
//            Task {
//                for await data in Activity<MeteorAttributes>.pushToStartTokenUpdates {
//                    let token = data.hexadecimalString
//                    print("🌊 Activity PushToStart Token: \(token)")
//                    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.liveDeviceTokenKey)
//                }
//            }
//        }
//    }
//    
//    func betaStart(color: Int) {
//        Task {
//            if Activity<MeteorAttributes>.activities.isEmpty == false {
//                await endLiveActivity()
//            }
//            await push(timestamp: Date.timestamp, liveColor: color, isHide: true)
//            await loadLiveActivity()
//        }
//    }
//    
//    func loadLiveActivity() async {
//        guard let activity = Activity<MeteorAttributes>.activities.first else { return }
//        await observeActivity(activity: activity)
//    }
//    
//    func startLiveActivity(text: String) -> Bool {
//        if ActivityAuthorizationInfo().areActivitiesEnabled {
//            UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
//            
//            Task {
//                // MARK: - Live 타임아웃 때 Local notification 등록
//                let contents = UNMutableNotificationContent()
//                contents.title = NSLocalizedString("⚠️ Live Expired", comment: "")
//                contents.body = text
//                contents.sound = UNNotificationSound.default
//                let twelveHours: TimeInterval = 12 * 60 * 60
//                
//                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: twelveHours, repeats: false)
//                let request = UNNotificationRequest(identifier: "live", content: contents, trigger: trigger)
//                
//                do {
//                    try await UNUserNotificationCenter.current().add(request)
//                } catch {
//                    print(error.localizedDescription)
//                }
//                // MARK: -
//                
//                let attributes = MeteorAttributes()
//                let state = MeteorAttributes.ContentState(
//                    liveText: text,
//                    liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
//                    hideContentOnLockScreen: UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey)
//                )
//                let content = ActivityContent(state: state, staleDate: .distantFuture)
//                
//                do {
//                    let activity = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
//                    await observeActivity(activity: activity)
//                    
//                } catch {
//                    print(error.localizedDescription)
//                }
//            }
//            return true
//        } else {
//            return false
//        }
//    }
//    
//    private func observeActivity(activity: Activity<MeteorAttributes>) async {
//        await withTaskGroup(of: Void.self) { group in
////            guard let activity = Activity<MeteorWidgetAttributes>.activities.first else { return }
//            group.addTask { @MainActor in
//                for await activityState in activity.activityStateUpdates {
//                    print("🌈🌈🌈🌈🌈🌈🌈")
//                    if activityState == .dismissed {
//                        await self.endLiveActivity()
//                        
//                        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveKey) {
//                            await self.push(timestamp: Date.timestamp, liveColor: 2, isHide: true)
//                            await self.loadLiveActivity()
//                        }
//                    }
//                }
//            }
//            
//            if #available(iOS 17.2, *) {
//                group.addTask { @MainActor in
//                    for await pushToken in Activity<MeteorAttributes>.pushToStartTokenUpdates {
//                        let pushTokenString = pushToken.hexadecimalString
//                        print("live push token: \(pushTokenString)")
//                    }
//                }
//            }
//        }
//    }
//    
//    func endLiveActivity() async {
//        // MARK: - Local notification 해제
//        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["live"])
//        
//        let finalState = MeteorAttributes.ContentState(liveText: "none",
//                                                             liveColor: 0,
//                                                             hideContentOnLockScreen: false
//        )
//        let finalContent = ActivityContent(state: finalState, staleDate: nil)
//        
//        for activity in Activity<MeteorAttributes>.activities {
//            await activity.end(finalContent, dismissalPolicy: .immediate)
//            print("Ending the Live Activity(Timer): \(activity.id)")
//        }
//    }
//    
//    func isLiveActivityAlive() -> Bool {
//        guard let activity = Activity<MeteorAttributes>.activities.first else { return false }
//        let activityState = activity.activityState
//        switch activityState {
//        case .dismissed:
//            return false
//        default:
//            return true
//        }
//    }
//    
//    func push(timestamp: Int, liveColor: Int, isHide: Bool) async {
//        guard let p8Payload = FileParser.parse() else { return }
//        do {
//            let jsonWebToken = try JSONWebToken(keyID: FileParser.keyID, teamID: FileParser.teamID, p8Payload: p8Payload)
//            print("🍓 jsonWebToken : \(jsonWebToken.token)")
//            let authenticationToken = jsonWebToken.token
//            let deviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveDeviceTokenKey) ?? ""
//            let payload =
//"""
//{
//    "aps": {
//        "timestamp": \(timestamp),
//        "event": "start",
//        "content-state": {
//            "liveText": "",
//            "liveColor": \(liveColor),
//            "hideContentOnLockScreen": \(isHide)
//        },
//        "attributes-type": "MeteorAttributes",
//        "attributes": {
//            "liveText": "",
//            "liveColor": \(liveColor),
//            "hideContentOnLockScreen": \(isHide)
//        },
//        "alert": {
//            "title": {
//                "loc-key": "%@ is on an adventure!"
//            },
//            "body": {
//                "loc-key": "%@ found a sword!",
//                "loc-args": ["Live"]
//            }
//        }
//    }
//}
//"""
//            guard let request = APNSManager().urlRequest(
//                authenticationToken: authenticationToken,
//                deviceToken: deviceToken,
//                payload: payload) else { return }
//            ///
//            let (data, response) = try await URLSession.shared.data(for: request)
//            var messages = [String]()
//            
//            if let description = String(data: data, encoding: .utf8),
//               !description.isEmpty {
//                messages.append("Payload: \(description)")
//            }
//            
//            if let response = response as? HTTPURLResponse {
//                var description = response.description
//                let regex = try! NSRegularExpression(pattern: "<.*:.*x.*>", options: NSRegularExpression.Options.caseInsensitive)
//                let range = NSMakeRange(0, description.count)
//                description = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "Response:")
//                if let url = response.url {
//                    messages.append("URL: \(url)")
//                }
//                
//                messages.append("Status Code: \(response.statusCode) (\(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))")
//                
//                if let allHeaderFields = response.allHeaderFields as? [String: String] {
//                    messages.append("Header: \(allHeaderFields.description)")
//                }
//            }
//            print("🍖\(messages.compactMap { $0 } .joined(separator: "\n")) \n-----")
//            ///
//            
//        /*
//            let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                var messages = [ error?.localizedDescription ]
//                
//                if let response = response as? HTTPURLResponse {
//                    var description = response.description
//                    let regex = try! NSRegularExpression(pattern: "<.*:.*x.*>", options: NSRegularExpression.Options.caseInsensitive)
//                    let range = NSMakeRange(0, description.count)
//                    description = regex.stringByReplacingMatches(in: description, options: [], range: range, withTemplate: "Response:")
//                    if let url = response.url {
//                        messages.append("URL: \(url)")
//                    }
//                    
//                    messages.append("Status Code: \(response.statusCode) (\(HTTPURLResponse.localizedString(forStatusCode: response.statusCode)))")
//                    
//                    if let allHeaderFields = response.allHeaderFields as? [String: String] {
//                        messages.append("Header: \(allHeaderFields.description)")
//                    }
//                }
//                
//                if let data = data,
//                   let description = String(data: data, encoding: .utf8),
//                   !description.isEmpty {
//                    messages.append("Payload: \(description)")
//                }
//                print("🍖\(messages.compactMap { $0 } .joined(separator: "\n")) \n-----")
//            }
//            task.resume()
//            */
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//}
