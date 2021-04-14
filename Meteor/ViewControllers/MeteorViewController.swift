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
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var eraseTextButton: UIButton!
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var content: String = ""
    var notificationIndex = 0
    var notice = ["내용을 작성하고 보내기를 누르면 알림으로 받을 수 있어요.","알림은 3개까지 쌓이고, 먼저 온 알림부터 순차적으로 삭제됩니다.","알림 창에 표시할 수 있는 텍스트의 길이에는 한계가 있습니다!"]
    var noticeIndex = 0
    
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
        
        noticeLabel.text = notice[0]
        pageControl.numberOfPages = notice.count
        noticeView.layer.cornerRadius = 15
        
        eraseTextButton.isHidden = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: { (didAllow, error) in
        })
        UNUserNotificationCenter.current().delegate = self
    }
    
    @IBAction func swipeLeftNoticeView(_ sender: UISwipeGestureRecognizer) {
        notificationIndex += 1
        if notificationIndex > notice.count - 1 {
            notificationIndex = 0
        }
        noticeLabel.text = notice[notificationIndex]
        pageControl.currentPage = notificationIndex
    }
    
    @IBAction func swipeRightNoticeView(_ sender: UISwipeGestureRecognizer) {
        notificationIndex -= 1
        if notificationIndex < 0 {
            notificationIndex = notice.count - 1
        }
        noticeLabel.text = notice[notificationIndex]
        pageControl.currentPage = notificationIndex
    }

    @IBAction func pageChanged(_ sender: UIPageControl) {
        noticeLabel.text = notice[pageControl.currentPage]
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

        notificationIndex += 1
        if notificationIndex > 2 {
            notificationIndex = 0
        }

        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(content)"
        //        contents.badge = 1

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)

        let request = UNNotificationRequest(identifier: "\(notificationIndex)timerdone", content: contents, trigger: trigger)
        print(notificationIndex)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)

        meteorTextField.resignFirstResponder()

        //탭틱
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
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
