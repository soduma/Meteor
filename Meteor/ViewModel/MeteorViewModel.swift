//
//  MeteorViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/05.
//

import Foundation
import UIKit.UIWindow
import Firebase

class MeteorViewModel {
    let db = Database.database().reference()
    var noticeList = [NSLocalizedString("notice0", comment: ""),
                  NSLocalizedString("notice1", comment: ""),
                  NSLocalizedString("notice2", comment: ""),
                  NSLocalizedString("notice3", comment: ""),
                  NSLocalizedString("notice4", comment: "")]
    
    func getFirebaseAdIndex(completion: @escaping (Int) -> Void) {
        db.child(adIndex).observeSingleEvent(of: .value) { snapshot in
            let value = snapshot.value as? Int ?? 0
            completion(value)
        }
    }
    
    func checkFirstAppLaunch() {
        if UserDefaults.standard.bool(forKey: FirstLaunch) == false {
            UserDefaults.standard.set(true, forKey: FirstLaunch)
            UserDefaults.standard.set(true, forKey: VibrateState)
        }
    }
    
    func checkApperanceMode(window: UIWindow) {
        if UserDefaults.standard.bool(forKey: LightState) == true {
            window.overrideUserInterfaceStyle = .light
        } else if UserDefaults.standard.bool(forKey: DarkState) == true {
            window.overrideUserInterfaceStyle = .dark
        } else {
            window.overrideUserInterfaceStyle = .unspecified
        }
    }
    
    func checkRepeatIdling() -> Bool {
        if UserDefaults.standard.bool(forKey: RepeatIdling) {
            return true
        } else {
            return false
        }
    }
    
    func sendWithoutRepeat(text: String) {
        let notificationLimit = 8
        var lastIndex = UserDefaults.standard.integer(forKey: NotificationIndex)
        
        lastIndex += 1
        if lastIndex > notificationLimit {
            lastIndex = 0
        }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(text)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(lastIndex)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        UserDefaults.standard.set(lastIndex, forKey: NotificationIndex)
        
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
    
    func sendWithRepeat(text: String, duration: TimeInterval) {        
        let contents = UNMutableNotificationContent()
        contents.title = "ENDLESS METEOR :"
        contents.body = "\(text)"
        contents.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: true)
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
    
    func secondsToString(seconds: Int) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
}
