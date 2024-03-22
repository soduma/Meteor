//
//  MeteorViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation
import ActivityKit
import WidgetKit
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
    
    func initialAppLaunchSettings() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunchKey) == false {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.hapticStateKey)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.lockScreenStateKey)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.initialLaunchKey)
            UserDefaults.standard.set(LiveColor.red.rawValue, forKey: UserDefaultsKeys.liveColorKey)
            
            // 최초 위젯 이미지 생성
            guard let url = URL(string: SettingsViewModel.defaultURL) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    SettingsViewModel().setWidget(imageData: imageData)
                }
            }.resume()
        }
    }
    
    func checkAppearanceMode() {
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
    
    func checkEndlessIdling() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.endlessIdlingKey)
    }
    
    func checkLiveIdling() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveIdlingKey)
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
    
    func startLiveActivity(text: String) {
        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.liveIdlingKey)
        UserDefaults.standard.set(text, forKey: UserDefaultsKeys.liveTextKey)
        
        let attributes = MeteorWidgetAttributes(value: "none")
        let state = MeteorWidgetAttributes.ContentState(liveText: text,
                                                        liveColor: UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey),
                                                        hideContentOnLockScreen: UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey))
        let content = ActivityContent(state: state, staleDate: .distantFuture)
        
        do {
            _ = try Activity<MeteorWidgetAttributes>.request(attributes: attributes, content: content)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func endLiveActivity() async {
        let finalStatus = MeteorWidgetAttributes.ContentState(liveText: "none",
                                                              liveColor: 0,
                                                              hideContentOnLockScreen: false)
        let finalContent = ActivityContent(state: finalStatus, staleDate: nil)
        
        for activity in Activity<MeteorWidgetAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
        }
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
    
    func sendToFirebase(type: MeteorType, text: String, duration: Int) {
#if RELEASE
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        
        switch type {
        case .single:
            db.child("singleText")
                .child("\(locale)")
                .child(user)
                .child(date)
                .setValue(["text": text])
            
        case .endless:
            db.child("endlessText")
                .child("\(locale)")
                .child(user)
                .child(date)
                .setValue(["text": text, "timer": String(duration / 60)])
            
        case .live:
            db.child("liveText")
                .child("\(locale)")
                .child(user)
                .child(date)
                .setValue(["text": text])
        }
#endif
    }
}
