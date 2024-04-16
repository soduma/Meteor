//
//  MeteorViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation
import ActivityKit
import WidgetKit
import SwiftData
import FirebaseDatabase
import OSLog

enum MeteorType {
    case single
    case endless
    case live
}

class MeteorViewModel {
    private let db = Database.database().reference()
    var meteorType = MeteorType.single
    var meteorText = ""
    let noticeList = [NSLocalizedString("notice0", comment: ""),
                      NSLocalizedString("notice1", comment: ""),
                      NSLocalizedString("notice2", comment: ""),
                      NSLocalizedString("notice3", comment: ""),
                      NSLocalizedString("notice4", comment: "")]
    
//    var currentActivity: Activity<MeteorWidgetAttributes>?
//    var activityState: ActivityState?
//    
//    init(currentActivity: Activity<MeteorWidgetAttributes>? = nil, activityState: ActivityState? = nil) {
//        self.currentActivity = currentActivity
//        self.activityState = activityState
//    }
    
    func initialAppLaunchSettings() async {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunchKey) == false {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hapticStateKey)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.lockScreenStateKey)
            UserDefaults.standard.set(LiveColor.red.rawValue, forKey: UserDefaultsKeys.liveColorKey)
            
            // 최초 위젯 이미지 생성
            Task {
                guard let url = URL(string: "https://source.unsplash.com/featured/?seoul") else { return }
                let (imageData, _) = try await URLSession.shared.data(from: url)
                SettingsViewModel().setWidget(imageData: imageData)
            }
            
        } else {
            checkAppearanceMode()
            resetCustomReviewCount()
            await loadLiveActivity()
        }
    }
    
    func checkAppearanceMode() {
        DispatchQueue.main.async {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            let window = windowScene?.windows.first
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.lightStateKey) == true {
                window?.overrideUserInterfaceStyle = .light
            } else if UserDefaults.standard.bool(forKey: UserDefaultsKeys.darkStateKey) == true {
                window?.overrideUserInterfaceStyle = .dark
            } else {
                window?.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    func isEndlessIdling() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.endlessIdlingKey)
    }
    
    func sendSingleMeteor(text: String) {
        var index = UserDefaults.standard.integer(forKey: UserDefaultsKeys.singleIndexKey)
        index += 1
        if index > singleLimit {
            index = 0
        }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(text)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(index)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(index, forKey: UserDefaultsKeys.singleIndexKey)
    }
    
    func sendEndlessMeteor(text: String, duration: Int) {
        UserDefaults.standard.set(duration, forKey: UserDefaultsKeys.endlessDurationKey)
        
        let contents = UNMutableNotificationContent()
        contents.title = "ENDLESS METEOR :"
        contents.body = text
        contents.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: true)
        let request = UNNotificationRequest(identifier: "timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func setEndlessTimerLabel(triggeredDate: Date, duration: Int) -> String {
        var remainSeconds: Int
        let passedSeconds = Int(round(Date().timeIntervalSince(triggeredDate)))
        print(passedSeconds)
        
        if passedSeconds < duration {
            remainSeconds = duration - passedSeconds
        } else {
            remainSeconds = duration - (passedSeconds % duration)
        }
        return String.secondsToString(seconds: remainSeconds)
    }
    
    /// 앱 업데이트 후 너무 이른 customReview 방지
    func resetCustomReviewCount() {
        let lastVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionKey)
        let currentVersion = SettingsViewModel().getCurrentVersion()
        
        if lastVersion != currentVersion {
            let reviewCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.customAppReviewCountKey)
            if customReviewLimit < reviewCount {
                UserDefaults.standard.set(customReviewReset, forKey: UserDefaultsKeys.customAppReviewCountKey)
            }
        }
    }
    
    func sendToFirebase(type: MeteorType, text: String, duration: Int) {
        switch type {
        case .single:
            firebase(kind: "2_singleText", content: text)
        case .endless:
            firebase(kind: "3_endlessText", content: text, duration: duration)
        case .live:
            firebase(kind: "4_liveText", content: text)
        }
    }
    
    private func firebase(kind: String, content: String, duration: Int = 0) {
#if RELEASE
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        let version = SettingsViewModel().getCurrentVersion().replacingOccurrences(of: ".", with: "_")
        let text = content.replacingOccurrences(of: "\n", with: "/-/")
        var value: Any? {
            if kind == "3_endlessText" {
                ["text": text, "duration": duration / 60]
            } else if kind == "4_liveText" {
                ["text": text, "liveColor": UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey)]
            } else {
                ["text": text]
            }
        }
        
        self.db
            .child(version)
            .child(kind)
            .child(locale)
            .child(user)
            .child(date)
            .setValue(value)
#endif
    }
    
    @MainActor func saveHistory() {
        let container = try? ModelContainer(for: History.self, migrationPlan: HistoryMigrationPlan.self)
        let history = History(content: meteorText, timestamp: Date().timeIntervalSince1970)
        container?.mainContext.insert(history)
    }
}

extension MeteorViewModel {
    func loadLiveActivity() async {
        guard let activity = Activity<MeteorAttributes>.activities.first else { return }
        await observeActivity(activity: activity)
    }
    
    func startLiveActivity(text: String) -> Bool {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
            
            Task {
                // MARK: - Live 타임아웃 때 Local notification 등록
                let contents = UNMutableNotificationContent()
                contents.title = NSLocalizedString("⚠️ Live Expired", comment: "")
                contents.body = text
                contents.sound = UNNotificationSound.default
                let twelveHours: TimeInterval = 12 * 60 * 60
                
                let trigger = UNTimeIntervalNotificationTrigger(timeInterval: twelveHours, repeats: false)
                let request = UNNotificationRequest(identifier: "live", content: contents, trigger: trigger)
                
                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    print(error.localizedDescription)
                }
                // MARK: -
                
                let attributes = MeteorAttributes()
                let state = MeteorAttributes.ContentState(
                    liveText: text,
                    liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
                    hideContentOnLockScreen: UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey),
                    triggerDate: Int(Date().timeIntervalSince1970)
                )
                let content = ActivityContent(state: state, staleDate: .distantFuture)
                
                do {
                    let activity = try Activity<MeteorAttributes>.request(attributes: attributes, content: content, pushType: .token)
                    await observeActivity(activity: activity)
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            return true
        } else {
            return false
        }
    }
    
    private func observeActivity(activity: Activity<MeteorAttributes>) async {
        await withTaskGroup(of: Void.self) { group in
//            guard let activity = Activity<MeteorWidgetAttributes>.activities.first else { return }
            group.addTask { @MainActor in
                for await activityState in activity.activityStateUpdates {
                    print("🌈🌈🌈🌈🌈🌈🌈")
                    if activityState == .dismissed {
                        await self.endLiveActivity()
                    }
                }
            }
            
//            if #available(iOS 17.2, *) {
//                group.addTask { @MainActor in
//                    for await pushToken in Activity<MeteorAttributes>.pushToStartTokenUpdates {
//                        let pushTokenString = pushToken.hexadecimalString
//                        Logger().debug("live push token: \(pushTokenString)")
//                    }
//                }
//            }
        }
    }
    
    func endLiveActivity() async {
        // MARK: - Local notification 해제
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["live"])
        
        let finalState = MeteorAttributes.ContentState(liveText: "none",
                                                             liveColor: 0,
                                                             hideContentOnLockScreen: false,
                                                             triggerDate: Int(Date().timeIntervalSince1970)
        )
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        for activity in Activity<MeteorAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
        }
    }
    
    func isLiveActivityAlive() -> Bool {
        guard let activity = Activity<MeteorAttributes>.activities.first else { return false }
        let activityState = activity.activityState
        switch activityState {
        case .active, .ended:
            return true
        default:
            return false
        }
    }
}
