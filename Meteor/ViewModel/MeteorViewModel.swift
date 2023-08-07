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
    var notificationLimit = 0
    
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
        notificationLimit += 1
        if notificationLimit > 8 {
            notificationLimit = 0
        }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(text)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "\(notificationLimit)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
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
        UserDefaults.standard.set(true, forKey: RepeatIdling)
        
        let contents = UNMutableNotificationContent()
        contents.title = "ENDLESS METEOR :"
        contents.body = "\(text)"
        contents.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: duration, repeats: true)
        let request = UNNotificationRequest(identifier: "timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
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
