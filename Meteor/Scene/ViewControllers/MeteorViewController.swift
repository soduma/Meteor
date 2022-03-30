//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications
import GoogleMobileAds
import AppTrackingTransparency
import AdSupport
import Firebase
import AudioToolbox

class MeteorViewController: UIViewController {
    @IBOutlet weak var meteorHeadLabel: UILabel!
    @IBOutlet weak var meteorTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var eraseTextButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    
    @IBOutlet weak var repeatWorkingLabel: UILabel!
    @IBOutlet weak var repeatTimerLabel: UILabel!
    @IBOutlet weak var repeatCancelView: UIView!
    @IBOutlet weak var repeatCancelLabel: UILabel!
    
    var content = ""
    var notificationCountIndex = 0
    var noticeViewIndex = 0

    var notice = [NSLocalizedString("notice0", comment: ""),
                  NSLocalizedString("notice1", comment: ""),
                  NSLocalizedString("notice2", comment: ""),
                  NSLocalizedString("notice3", comment: ""),
                  NSLocalizedString("notice4", comment: "")]
    
    var db = Database.database().reference()
    var firebaseAdCountIndex = 0

    // 구글광고!!!!!!!!!!!!!!!!!!!!
    private var interstitial: GADInterstitialAd?
    var adIndex = 0
    var adUnitID1 = ""
    var adUnitID2 = ""
    // --------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFirstAppLaunch()
        changeApperanceMode()
        layout()
        
        adIndex = UserDefaults.standard.integer(forKey: "adIndex")
        
        db.child("adIndex").observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.firebaseAdCountIndex = snapshot.value as? Int ?? 0
//            print(self.firebaseIndex)
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
        
        //앱 강제종료시 타이머 유무 체크
        if UserDefaults.standard.bool(forKey: "repeatIdling") == true {
            self.repeatWorkingLabel.alpha = 1
            self.repeatTimerLabel.alpha = 1
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(notiAuthCheck), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(checkNetworkConnection), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        ATTrackingManager.requestTrackingAuthorization(completionHandler: { [weak self] status in
            // Tracking authorization completed. Start loading ads here.
            // loadAd()
            self?.firstLoadAd()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func inputContent(_ sender: UITextField) {
        //알림 권한
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            if settings.authorizationStatus == .denied {
                print("Push notification is NOT enabled")
                
                DispatchQueue.main.async {
                    self.authView.isHidden = false
                    self.meteorTextField.resignFirstResponder()
                    self.authViewBottom.constant = -self.view.bounds.height
                    self.meteorTextField.text = ""
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.authView.layoutIfNeeded()
                    })
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
    
    @IBAction func swipeLeftNoticeView(_ sender: UISwipeGestureRecognizer) {
        noticeViewIndex += 1
        if noticeViewIndex > notice.count - 1 {
            noticeViewIndex = 0
        }
        noticeLabel.text = notice[noticeViewIndex]
        pageControl.currentPage = noticeViewIndex
    }
    
    @IBAction func swipeRightNoticeView(_ sender: UISwipeGestureRecognizer) {
        noticeViewIndex -= 1
        if noticeViewIndex < 0 {
            noticeViewIndex = notice.count - 1
        }
        noticeLabel.text = notice[noticeViewIndex]
        pageControl.currentPage = noticeViewIndex
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        noticeLabel.text = notice[pageControl.currentPage]
        noticeViewIndex = pageControl.currentPage
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func tapEraseButton(_ sender: UIButton) {
        meteorTextField.text = ""
        eraseTextButton.isHidden = true
    }
    
    @IBAction func tapRepeatButton(_ sender: UIButton) {
        repeatButton.isSelected = !repeatButton.isSelected
        
        if repeatButton.isSelected {
            meteorHeadLabel.text = "ENDLESS \nMETEOR :"
            timePicker.isEnabled = true
            timePicker.isHidden = false
        } else {
            meteorHeadLabel.text = "METEOR :"
            timePicker.isEnabled = false
            timePicker.isHidden = true
        }
        
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        print(timePicker.countDownDuration)
    }
    
    //MARK: - SEND LOGIC
    @IBAction func tapSendButton(_ sender: UIButton) {
        guard let detail = meteorTextField.text, detail.isEmpty == false else {
            print("Stop Repeat")
            
            meteorTextField.resignFirstResponder()
            repeatWorkingLabel.alpha = 0
            repeatTimerLabel.alpha = 0
            repeatCancelView.alpha = 1
            repeatCancelLabel.text = NSLocalizedString("Endless Canceled", comment: "")
            
            UIView.animate(withDuration: 0.5,
                           delay: 1.5,
                           options: .allowUserInteraction,
                           animations: { self.repeatCancelView.alpha = 0 },
                           completion: nil)
            
            UserDefaults.standard.set(false, forKey: "repeatIdling")
            
            if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            return UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
        
        showAD()
        
        notificationCountIndex += 1
        if notificationCountIndex > 8 {
            notificationCountIndex = 0
//            print("notificationCountIndex: \(notificationCountIndex)")
        }
                
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
        }
        
        if repeatButton.isSelected {
            guard UserDefaults.standard.bool(forKey: "repeatIdling") == false else {
                // 타이머가 이미 있으면 거절
                repeatCancelLabel.text = NSLocalizedString("Endless already been set", comment: "")
                repeatCancelView.alpha = 1
                
                UIView.animate(withDuration: 0.5,
                               delay: 1.5,
                               options: .allowUserInteraction,
                               animations: { self.repeatCancelView.alpha = 0 },
                               completion: nil)

                if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
                    AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
                }
                return
            }
            sendWithRepeat()
            UserDefaults.standard.set(true, forKey: "repeatIdling")
        } else {
            sendWithoutRepeat()
        }
        
        meteorTextField.resignFirstResponder()
        repeatButton.isSelected = false
        meteorHeadLabel.text = "METEOR :"
        timePicker.isEnabled = false
        timePicker.isHidden = true
    }
}

extension MeteorViewController {
    @objc func checkNetworkConnection() {
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
    }
    
    @objc func notiAuthCheck() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                print("Push notification is enabled")
                self?.prepareAuthView()
            }
        }
    }
    
    private func showAD() {
        // 구글광고!!!!!!!!!!!!!!!!!!!!!!
        adIndex += 1
//        print("adIndex: \(adIndex)")

        if adIndex >= firebaseAdCountIndex {
            adIndex = 0
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
        } else if adIndex > 50 {
            adIndex = 0
        }
        UserDefaults.standard.set(adIndex, forKey: "adIndex")
        // --------------------------------
    }
    
    private func sendWithRepeat() {
        let contents = UNMutableNotificationContent()
        contents.title = "ENDLESS METEOR :"
        contents.body = "\(content)"
        contents.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timePicker.countDownDuration, repeats: true)
        let request = UNNotificationRequest(identifier: "timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            guard let self = self else { return }
            self.repeatWorkingLabel.alpha = 1
            self.repeatTimerLabel.alpha = 1
        })
        
        // 타이머 성공
        let clickDate = Date()
        let timePickerSecond = Int(timePicker.countDownDuration)
//            let timePickerSecond = 5
        var remainSeconds = 0
        self.repeatTimerLabel.text = secondsToString(seconds: timePickerSecond)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let passSecond = Int(round(Date().timeIntervalSince(clickDate)))
            print(passSecond)
            
            if passSecond < timePickerSecond {
                remainSeconds = timePickerSecond - passSecond
                self.repeatTimerLabel.text = self.secondsToString(seconds: remainSeconds)
            } else {
                remainSeconds = timePickerSecond - (passSecond % timePickerSecond)
                self.repeatTimerLabel.text = self.secondsToString(seconds: remainSeconds)
            }
            
            if UserDefaults.standard.bool(forKey: "repeatIdling") == false {
                timer.invalidate()
                print("timer invalidate")
            }
        }
        
        if let text = meteorTextField.text {
            let timer = timePicker.countDownDuration
            let locale = TimeZone.current.identifier
            guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
            self.db.child("repeatText").child(user).childByAutoId().setValue(["text": text, "timer": timer / 60, "locale": locale])
        }
    }
    
    private func sendWithoutRepeat() {
        let contents = UNMutableNotificationContent()
        contents.title = "METEOR :"
        contents.body = "\(content)"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.5, repeats: false)
        let request = UNNotificationRequest(identifier: "\(notificationCountIndex)timerdone", content: contents, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        if let text = meteorTextField.text {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
            
            let dateTime = dateFormatter.string(from: Date())
            let locale = TimeZone.current.identifier

            guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
            self.db.child("meteorText").child(user).childByAutoId().setValue(["text": text, "time": dateTime, "locale": locale])
        }
    }
    
    private func layout() {
        noticeLabel.text = notice[0]
        noticeView.layer.cornerRadius = 15
        pageControl.numberOfPages = notice.count
        
        authView.layer.cornerRadius = 20
        authView.isHidden = true
        
        eraseTextButton.isHidden = true
        repeatButton.isSelected = false
        timePicker.isEnabled = false
        timePicker.isHidden = true
        
        repeatWorkingLabel.alpha = 0
        repeatTimerLabel.alpha = 0
        repeatCancelView.alpha = 0
    }
    
    private func checkFirstAppLaunch() {
        if UserDefaults.standard.bool(forKey: "First Launch") == false {
            // first
            UserDefaults.standard.set(true, forKey: "First Launch")
            UserDefaults.standard.set(true, forKey: "vibrateSwitch")
            UserDefaults.standard.set(true, forKey: "imageSwitch")
        } else {
            // not first
            UserDefaults.standard.set(true, forKey: "First Launch")
        }
    }
    
    private func changeApperanceMode() {
        if let window = UIApplication.shared.windows.first {
            if UserDefaults.standard.bool(forKey: "lightState") == true {
                window.overrideUserInterfaceStyle = .light
            } else if UserDefaults.standard.bool(forKey: "darkState") == true {
                window.overrideUserInterfaceStyle = .dark
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
    }
    
    private func secondsToString(seconds: Int) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
}

extension MeteorViewController : UNUserNotificationCenterDelegate {
    //To display notifications when app is running  inforeground
    //viewDidLoad() UNUserNotificationCenter.current().delegate = self
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}

// 구글광고!!!!!!!!!!!!!!!!!!!!!!
extension MeteorViewController: GADFullScreenContentDelegate {
    private func firstLoadAd() {
#if DEBUG
        adUnitID1 = "ca-app-pub-3940256099942544/4411468910" // 테스트
#else
        adUnitID1 = "ca-app-pub-1960781437106390/8071718444" // 전면 1
#endif
        
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID1,
                               request: request,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        })
    }

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
#if DEBUG
        adUnitID2 = "ca-app-pub-3940256099942544/4411468910" // 테스트
#else
        adUnitID2 = "ca-app-pub-1960781437106390/9294984986" // 전면 2
#endif
        
        let request2 = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID2,
                               request: request2,
                               completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                return
            }
            interstitial = ad
            interstitial?.fullScreenContentDelegate = self
        })
        print("Ad did dismiss full screen content.")
    }
}
// --------------------------------
