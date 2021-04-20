//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications
import GoogleMobileAds
import SystemConfiguration

class MeteorViewController: UIViewController, GADFullScreenContentDelegate {
    
    @IBOutlet weak var meteorTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var eraseTextButton: UIButton!
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authViewTop: NSLayoutConstraint!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    
    var content: String = ""
    var notificationIndex = 0
    var noticeIndex = 0
    var notice = ["내용을 작성하고 보내기를 누르면 알림으로 받을 수 있어요.",
                  "알림은 5개까지 쌓이고, 먼저 온 알림부터 순차적으로 삭제됩니다.",
                  "알림 창에 표시할 수 있는 텍스트의 길이에는 한계가 있습니다!"]
    
    // 구글광고!!!!!!!!!!!!!!!!!!!!!!
    private var interstitial: GADInterstitialAd?
    var adIndex = 0
    // --------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 구글광고!!!!!!!!!!!!!!!!!!!!!!
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                               }
        )
        // --------------------------------
        
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
        noticeView.layer.cornerRadius = 15
        pageControl.numberOfPages = notice.count
        
        authView.layer.cornerRadius = 20
        prepareAuthView()
        
        eraseTextButton.isHidden = true
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert,.sound], completionHandler: { (didAllow, error) in
        })
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == false {
//            sendButton.isEnabled = true
//            print("Internet Connection Available!")
//        } else {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(notiAuthCheck), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    // 구글광고!!!!!!!!!!!!!!!!!!!!!!
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content.")
    }
    
    /// Tells the delegate that the ad presented full screen content.
    func adDidPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        
        let request2 = GADRequest()
        GADInterstitialAd.load(withAdUnitID:"ca-app-pub-3940256099942544/4411468910",
                               request: request2,
                               completionHandler: { [self] ad, error in
                                if let error = error {
                                    print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                    return
                                }
                                interstitial = ad
                                interstitial?.fullScreenContentDelegate = self
                               }
        )
        print("Ad did dismiss full screen content.")
    }
    // --------------------------------
    
    @objc func notiAuthCheck() {        
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .authorized {
                print("Push notification is enabled")
                self.prepareAuthView()
            }
        }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
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
        
        // 구글광고!!!!!!!!!!!!!!!!!!!!!!
        adIndex += 1
        print("adIndex: \(adIndex)")
        
        if adIndex == 1 {
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        }
        // --------------------------------
        
        if adIndex == 9 {
            adIndex = 0
        }
        
        notificationIndex += 1
        if notificationIndex > 4 {
            notificationIndex = 0
        }
        
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(content)"
        //        contents.badge = 1
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(notificationIndex)timerdone", content: contents, trigger: trigger)
        print("notificationIndex: \(notificationIndex)")
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        meteorTextField.resignFirstResponder()
        
        //탭틱
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
    }
    
    @IBAction func inputContent(_ sender: UITextField) {
        
        //알림 권한
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { (settings) in
            
            if settings.authorizationStatus == .denied {
                print("Push notification is NOT enabled")
                
                DispatchQueue.main.async {
                    self.meteorTextField.resignFirstResponder()
                    self.authViewBottom.constant = -self.view.bounds.height
                    UIView.animate(withDuration: 0.5, animations: { self.authView.layoutIfNeeded() })
                    self.meteorTextField.text = ""
                }
            }
        }
        
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

// 인터넷 연결확인
public class Reachability {
    
    class func isConnectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        /* Only Working for WIFI
         let isReachable = flags == .reachable
         let needsConnection = flags == .connectionRequired
         
         return isReachable && !needsConnection
         */
        
        // Working for Cellular and WIFI
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        let ret = (isReachable && !needsConnection)
        
        return ret
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
