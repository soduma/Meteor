//
//  MeteorViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation
import SwiftData
import FirebaseDatabase

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
    
    private let liveManager = LiveActivityManager.shared
    
    func appLaunchSettings() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.launchedBeforeKey) {
            checkAppearanceMode()
            liveManager.loadActivity()
            
        } else {            
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hapticStateKey)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.liveContentHideStateKey)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.alwaysOnLiveStateKey)
            UserDefaults.standard.set(LiveColor.red.rawValue, forKey: UserDefaultsKeys.liveColorKey)
            UserDefaults.standard.set(LiveAlignment.left.rawValue, forKey: UserDefaultsKeys.liveAlignmentKey)
            
            // 최초 위젯 이미지 생성
            Task {
                guard let url = URL(string: "https://source.unsplash.com/featured/?seoul") else { return }
                let (imageData, _) = try await URLSession.shared.data(from: url)
                SettingsViewModel().setWidget(imageData: imageData)
            }
        }
    }
    
    private func checkAppearanceMode() {
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
        contents.title = "Meteor :"
        contents.body = "\(text)"
        contents.sound = .default
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.timeSensitiveStateKey) {
            contents.interruptionLevel = .timeSensitive
        } else {
            contents.interruptionLevel = .active
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(index)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(index, forKey: UserDefaultsKeys.singleIndexKey)
    }
    
    func sendEndlessMeteor(text: String, duration: Int) {
        UserDefaults.standard.set(duration, forKey: UserDefaultsKeys.endlessDurationKey)
        
        let contents = UNMutableNotificationContent()
        contents.title = "Endless Meteor :"
        contents.body = text
        contents.sound = .default
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.timeSensitiveStateKey) {
            contents.interruptionLevel = .timeSensitive
        } else {
            contents.interruptionLevel = .active
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: true)
        let request = UNNotificationRequest(identifier: "endlesstimer", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func getEndlessTimerString(triggeredDate: Date, duration: Int) -> String {
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
        let currentVersion = SettingsViewModel.getCurrentVersion()
        
        if lastVersion != currentVersion {
            UserDefaults.standard.set(10, forKey: UserDefaultsKeys.customAppReviewCountKey)
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
        let dateFormatter1 = DateFormatter()
        dateFormatter1.dateFormat = "yyyy-MM-dd"
        let date1 = dateFormatter1.string(from: Date())
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date2 = dateFormatter2.string(from: Date())
        let locale = TimeZone.current.identifier
        let version = SettingsViewModel.getCurrentVersion().replacingOccurrences(of: ".", with: "_")
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
            .child(date1)
            .child(kind)
            .child(locale)
            .child(user)
            .child(date2)
            .setValue(value)
#endif
    }
    
    @MainActor func saveHistory() {
        let container = try? ModelContainer(for: History.self, migrationPlan: HistoryMigrationPlan.self)
        let history = History(content: meteorText, timestamp: Date().timeIntervalSince1970)
        container?.mainContext.insert(history)
    }
}
