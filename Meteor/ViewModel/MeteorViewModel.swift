//
//  MeteorViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation
import UIKit.UIWindow
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
    var noticeList = [NSLocalizedString("notice0", comment: ""),
                      NSLocalizedString("notice1", comment: ""),
                      NSLocalizedString("notice2", comment: ""),
                      NSLocalizedString("notice3", comment: ""),
                      NSLocalizedString("notice4", comment: ""),
                      NSLocalizedString("notice5", comment: "")]
    
//    func getFirebaseAdIndex(completion: @escaping (Int) -> Void) {
//        db.child(adIndex).observeSingleEvent(of: .value) { snapshot in
//            let value = snapshot.value as? Int ?? 0
//            completion(value)
//        }
//    }
    
    func IntialAppLaunchSettings() {
        if UserDefaults.standard.bool(forKey: initialLaunchKey) == false {
            UserDefaults.standard.set(true, forKey: hapticStateKey)
            UserDefaults.standard.set(true, forKey: lockScreenStateKey)
            UserDefaults.standard.set(true, forKey: initialLaunchKey)
            
            // 초기 위젯 이미지 생성
            guard let url = URL(string: SettingViewModel.defaultURL) else { return }
            URLSession.shared.dataTask(with: url) { (data, _, _) in
                guard let imageData = data else { return }
                
                DispatchQueue.main.async {
                    SettingViewModel().setWidget(imageData: imageData)
                }
            }.resume()
        }
    }
    
    func checkApperanceMode(window: UIWindow) {
        if UserDefaults.standard.bool(forKey: lightStateKey) == true {
            window.overrideUserInterfaceStyle = .light
        } else if UserDefaults.standard.bool(forKey: darkStateKey) == true {
            window.overrideUserInterfaceStyle = .dark
        } else {
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func checkEndlessIdling() -> Bool {
        if UserDefaults.standard.bool(forKey: endlessIdlingKey) {
            return true
        } else {
            return false
        }
    }
    
    func checkLiveIdling() -> Bool {
        if UserDefaults.standard.bool(forKey: liveIdlingKey) {
            return true
        } else {
            return false
        }
    }
    
    func sendSingleMeteor(text: String) {
        let notificationLimit = 8
        var index = UserDefaults.standard.integer(forKey: singleIndexKey)
        
        index += 1
        if index > notificationLimit {
            index = 0
        }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(text)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(index)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(index, forKey: singleIndexKey)
        
        // for Firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.db
            .child("meteorText")
            .child(user)
            .childByAutoId()
            .setValue(["text": text, "time": dateTime, "locale": locale])
    }
    
    func sendEndlessMeteor(text: String, duration: Int) {
        UserDefaults.standard.set(duration, forKey: endlessDurationKey)
        
        let contents = UNMutableNotificationContent()
        contents.title = "ENDLESS METEOR :"
        contents.body = text
        contents.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(duration), repeats: true)
        let request = UNNotificationRequest(identifier: "timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        // for Firebase
        let locale = TimeZone.current.identifier
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.db
            .child("repeatText")
            .child(user)
            .childByAutoId()
            .setValue(["text": text, "timer": String(duration / 60), "locale": locale])
    }
    
    func startLiveActivity(text: String) {
        UserDefaults.standard.set(true, forKey: liveIdlingKey)
        UserDefaults.standard.set(text, forKey: liveTextKey)
        
        let attributes = MeteorWidgetAttributes(value: "none")
        let state = MeteorWidgetAttributes.ContentState(endlessText: text, lockscreen: UserDefaults.standard.bool(forKey: lockScreenStateKey))
        let content = ActivityContent(state: state, staleDate: .distantFuture)
        
        do {
            let activity = try Activity<MeteorWidgetAttributes>.request(attributes: attributes,
                                                                        content: content)
//            let activity = try Activity<MeteorWidgetAttributes>.request(
//                attributes: attributes,
//                contentState: contentState
//            )
            print(activity)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func endLiveActivity() async {
        let finalStatus = MeteorWidgetAttributes.ContentState(endlessText: "none", lockscreen: false)
        let finalContent = ActivityContent(state: finalStatus, staleDate: nil)
        
        for activity in Activity<MeteorWidgetAttributes>.activities {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            print("Ending the Live Activity(Timer): \(activity.id)")
        }
        
        if UserDefaults.standard.bool(forKey: liveIdlingKey) == false {
            UserDefaults.standard.removeObject(forKey: liveTextKey)
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
}
