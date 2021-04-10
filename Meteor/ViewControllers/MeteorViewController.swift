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
    @IBOutlet weak var eraseTextButton: UIButton!
    @IBOutlet weak var testView: UIView!
    
    var content: String = ""
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let window = UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {
                
                if UserDefaults.standard.bool(forKey: "lightState") == true {
                    window.overrideUserInterfaceStyle = .light
                } else if UserDefaults.standard.bool(forKey: "darkState") == true {
                    window.overrideUserInterfaceStyle = .dark
                } else {
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
        
        testView.layer.cornerRadius = 20
        
        eraseTextButton.isHidden = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: { (didAllow, error) in
        })
        UNUserNotificationCenter.current().delegate = self
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func tapEraseButton(_ sender: UIButton) {
        meteorTextField.text = ""
        eraseTextButton.isHidden = true
    }
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        guard let detail = meteorTextField.text, detail.isEmpty == false else { return }
        
        index += 1
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(content)"
        //        contents.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(index)timerdone", content: contents, trigger: trigger)
        print(index)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func inputContent(_ sender: UITextField) {
        if let inputContent = meteorTextField.text {
            content = inputContent
        }
        
        if meteorTextField.hasText {
            eraseTextButton.isHidden = false
        } else {
            eraseTextButton.isHidden = true
        }
    }
}

extension MeteorViewController : UNUserNotificationCenterDelegate {
    //To display notifications when app is running  inforeground
    
    //앱이 foreground에 있을 때. 즉 앱안에 있어도 push알림을 받게 해줍니다.
    //viewDidLoad()에 UNUserNotificationCenter.current().delegate = self를 추가해주는 것을 잊지마세요.
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) {
        let settingsViewController = UIViewController()
        settingsViewController.view.backgroundColor = .gray
        self.present(settingsViewController, animated: true, completion: nil)
    }
}
