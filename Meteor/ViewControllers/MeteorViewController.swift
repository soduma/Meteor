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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge], completionHandler: {didAllow, Error in
                                                                    print(didAllow)})
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        
        for index in 1...5 {
            
            let contents = UNMutableNotificationContent()
            contents.title = "METEOR:"
            contents.subtitle = "마바사"
            contents.body = "아자차카"
            contents.badge = NSNumber(value: index)
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(index)timerdone", content: contents, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
    
}
