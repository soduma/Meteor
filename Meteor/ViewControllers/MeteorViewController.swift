//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications

class MeteorViewController: UIViewController {
    
    @IBOutlet weak var meteorTextField: UITextField!
    @IBOutlet weak var meteorButton: UIButton!
    
    var content: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound,.badge], completionHandler: { (didAllow, error) in
        })
        
        UNUserNotificationCenter.current().delegate = self
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        guard let detail = meteorTextField.text, detail.isEmpty == false else { return }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(content)"
        contents.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "timerdone", content: contents, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    @IBAction func inputContent(_ sender: UITextField) {
        if let inputContent = meteorTextField.text {
            content = inputContent
        }
    }
}

extension MeteorViewController : UNUserNotificationCenterDelegate {
    //To display notifications when app is running  inforeground
    
    //앱이 foreground에 있을 때. 즉 앱안에 있어도 push알림을 받게 해줍니다.
    //viewDidLoad()에 UNUserNotificationCenter.current().delegate = self를 추가해주는 것을 잊지마세요.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        settingsViewController.view.backgroundColor = .gray
        self.present(settingsViewController, animated: true, completion: nil)
    }
}
