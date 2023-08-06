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

class MeteorViewController: UIViewController {
    @IBOutlet weak var meteorHeadLabel: UILabel!
    @IBOutlet weak var meteorTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var noticeView: UIView!
    @IBOutlet weak var noticeLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    @IBOutlet weak var moveToSettingButton: UIButton!
    
    @IBOutlet weak var repeatWorkingLabel: UILabel!
    @IBOutlet weak var repeatTimerLabel: UILabel!
    @IBOutlet weak var repeatCancelView: UIView!
    @IBOutlet weak var repeatCancelLabel: UILabel!
    
    let viewModel = MeteorViewModel()
    
    var meteorText = ""
    var noticeViewIndex = 0
    var noticeList = [NSLocalizedString("notice0", comment: ""),
                  NSLocalizedString("notice1", comment: ""),
                  NSLocalizedString("notice2", comment: ""),
                  NSLocalizedString("notice3", comment: ""),
                  NSLocalizedString("notice4", comment: "")]

    // MARK: ADMOB
    private var interstitial: GADInterstitialAd?
    var firebaseAdIndex = 0
    var currentAdIndex = 0
    
    #if DEBUG
    var adUnitID1 = "ca-app-pub-3940256099942544/4411468910" // 테스트 1
    var adUnitID2 = "ca-app-pub-3940256099942544/4411468910" // 테스트 2
    #else
    var adUnitID1 = "ca-app-pub-1960781437106390/8071718444" // 전면 1
    var adUnitID2 = "ca-app-pub-1960781437106390/9294984986" // 전면 2
    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.checkFirstAppLaunch()
        if let window = UIApplication.shared.windows.first {
            viewModel.checkApperanceMode(window: window)
        }
        
        currentAdIndex = UserDefaults.standard.integer(forKey: adIndex)
        viewModel.getAdIndex { [weak self] value in
            self?.firebaseAdIndex = value
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
        
        // 앱 강제종료시 타이머 유무 체크
        if viewModel.checkRepeatIdling() {
            [repeatWorkingLabel, repeatTimerLabel]
                .forEach { $0?.alpha = 1 }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkNotificationAuth),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkNetworkConnection),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
        
        ATTrackingManager.requestTrackingAuthorization { [weak self] status in
            // Tracking authorization completed. Start loading ads here.
            self?.firstLoadAd()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func inputContent(_ sender: UITextField) {
        guard let text = meteorTextField.text else { return }
        meteorText = text
        
        // 알림 권한 다시 확인
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
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
    }
    
    @IBAction func swipeLeftNoticeView(_ sender: UISwipeGestureRecognizer) {
        noticeViewIndex += 1
        if noticeViewIndex > noticeList.count - 1 {
            noticeViewIndex = 0
        }
        noticeLabel.text = noticeList[noticeViewIndex]
        pageControl.currentPage = noticeViewIndex
    }
    
    @IBAction func swipeRightNoticeView(_ sender: UISwipeGestureRecognizer) {
        noticeViewIndex -= 1
        if noticeViewIndex < 0 {
            noticeViewIndex = noticeList.count - 1
        }
        noticeLabel.text = noticeList[noticeViewIndex]
        pageControl.currentPage = noticeViewIndex
    }
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        noticeLabel.text = noticeList[pageControl.currentPage]
        noticeViewIndex = pageControl.currentPage
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func tapRepeatButton(_ sender: UIButton) {
        repeatButton.isSelected = !repeatButton.isSelected
        
        if repeatButton.isSelected {
            meteorHeadLabel.text = "ENDLESS \nMETEOR :"
            datePicker.isEnabled = true
            datePicker.isHidden = false
        } else {
            meteorHeadLabel.text = "METEOR :"
            datePicker.isEnabled = false
            datePicker.isHidden = true
        }
        
        viewModel.makeVibration(type: .rigid)
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        print(datePicker.countDownDuration)
    }
    
    @IBAction func tapMoveToSettingButton(_ sender: UIButton) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        if let text = meteorTextField.text, !text.isEmpty {
            showAD()
            
            switch repeatButton.isSelected {
            case true:
                if viewModel.checkRepeatIdling() == false {
                    viewModel.sendWithRepeat(text: meteorText, duration: datePicker.countDownDuration)
                    
                    setTimer()
                    
                    UIView.animate(withDuration: 0.1, animations: { [weak self] in
                        guard let self = self else { return }
                        self.repeatWorkingLabel.alpha = 1
                        self.repeatTimerLabel.alpha = 1
                    })
                    
                } else { // 타이머가 이미 있으면 거절
                    viewModel.makeVibration(type: .big)
                    repeatCancelLabel.text = NSLocalizedString("Endless already been set", comment: "")
                    repeatCancelView.alpha = 1
                    
                    UIView.animate(withDuration: 0.5,
                                   delay: 1.5,
                                   options: .allowUserInteraction,
                                   animations: { self.repeatCancelView.alpha = 0 },
                                   completion: nil)
                }
                
            case false:
                viewModel.makeVibration(type: .error)
                viewModel.sendWithoutRepeat(text: meteorText)
            }
            
            // 보낸 이후 UI초기화
            meteorTextField.resignFirstResponder()
            repeatButton.isSelected = false
            meteorHeadLabel.text = "METEOR :"
            datePicker.isEnabled = false
            datePicker.isHidden = true
            
        } else { // 끝없이 취소
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
            
            viewModel.updateUserDefaults(bool: false, key: repeatIdling)
            viewModel.makeVibration(type: .success)
            
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }
}

extension MeteorViewController {
    private func setLayout() {
        noticeLabel.text = noticeList[0]
        noticeView.layer.cornerRadius = 15
        pageControl.numberOfPages = noticeList.count
        
        authView.layer.cornerRadius = 20
        authView.isHidden = true
        moveToSettingButton.layer.cornerRadius = 20
        moveToSettingButton.clipsToBounds = true
        
        repeatButton.isSelected = false
        datePicker.isEnabled = false
        datePicker.isHidden = true
        
        [repeatWorkingLabel, repeatTimerLabel, repeatCancelView]
            .forEach { $0?.alpha = 0 }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
    }
    
    private func setTimer() {
        let triggeredDate = Date()
        let datePickerDuration = Int(datePicker.countDownDuration)
        var remainSecond = 0
        repeatTimerLabel.text = viewModel.secondsToString(seconds: datePickerDuration)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let passSecond = Int(round(Date().timeIntervalSince(triggeredDate)))
            print(passSecond)
            
            if passSecond < datePickerDuration {
                remainSecond = datePickerDuration - passSecond
                self.repeatTimerLabel.text = viewModel.secondsToString(seconds: remainSecond)
            } else {
                remainSecond = datePickerDuration - (passSecond % datePickerDuration)
                self.repeatTimerLabel.text = viewModel.secondsToString(seconds: remainSecond)
            }
            
            // MARK: 여기서 타이머 중지
            if viewModel.checkRepeatIdling() == false {
                timer.invalidate()
                print("timer invalidate")
            }
        }
    }
    
    @objc private func checkNetworkConnection() {
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
    }
    
    @objc private func checkNotificationAuth() {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                print("Push notification is enabled")
                self?.prepareAuthView()
            }
        }
    }
}

extension MeteorViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}

// MARK: ADMOB
extension MeteorViewController: GADFullScreenContentDelegate {
    private func showAD() {
        currentAdIndex += 1
        
        if currentAdIndex >= firebaseAdIndex {
            if interstitial != nil {
                interstitial?.present(fromRootViewController: self)
            } else {
                print("Ad wasn't ready")
            }
            currentAdIndex = 0
            
        } else if currentAdIndex > 50 { // exception: 상한선에 도달시 초기화
            currentAdIndex = 0
        }
        UserDefaults.standard.set(currentAdIndex, forKey: adIndex)
    }
    
    private func firstLoadAd() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID1,
                               request: request,
                               completionHandler: { [weak self] ad, error in
            guard let self = self else { return }
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

    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }

    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        let request2 = GADRequest()
        GADInterstitialAd.load(withAdUnitID: adUnitID2,
                               request: request2,
                               completionHandler: { [weak self] ad, error in
            guard let self = self else { return }
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
