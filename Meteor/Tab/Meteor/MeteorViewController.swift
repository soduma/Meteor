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
import Toast

class MeteorViewController: UIViewController {
    @IBOutlet weak var meteorHeadLabel: UILabel!
    @IBOutlet weak var meteorTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var endlessButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var endlessWorkingLabel: UILabel!
    @IBOutlet weak var endlessTimerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    @IBOutlet weak var moveToSettingButton: UIButton!
    
    let viewModel = MeteorViewModel()
    var toast = Toast.text("")
    var meteorText = ""
    
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
        
        currentAdIndex = UserDefaults.standard.integer(forKey: SavedAdIndex)
        viewModel.getFirebaseAdIndex { [weak self] value in
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
            [endlessWorkingLabel, endlessTimerLabel]
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
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        meteorTextField.resignFirstResponder()
    }
    
    @IBAction func tapEndlessButton(_ sender: UIButton) {
        endlessButton.isSelected = !endlessButton.isSelected
        
        if endlessButton.isSelected {
            meteorHeadLabel.text = "ENDLESS \nMETEOR :"
            datePicker.isEnabled = true
            datePicker.isHidden = false
        } else {
            meteorHeadLabel.text = "METEOR :"
            datePicker.isEnabled = false
            datePicker.isHidden = true
        }
        
        makeVibration(type: .rigid)
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
        toast.close()
        let toastConfig = ToastConfiguration(autoHide: true, enablePanToClose: false, displayTime: 2)
        
        if let text = meteorTextField.text, !text.isEmpty {
            meteorTextField.resignFirstResponder()
            showAD()
            
            switch endlessButton.isSelected {
            case true:
                if viewModel.checkRepeatIdling() == false {
                    setTimer()
                    makeVibration(type: .success)
                    viewModel.sendWithRepeat(text: meteorText, duration: datePicker.countDownDuration)
                                        
                    UIView.animate(withDuration: 0.1, animations: {
                        self.endlessWorkingLabel.alpha = 1
                        self.endlessTimerLabel.alpha = 1
                    })
                    
                    let title = NSLocalizedString("Endless", comment: "")
                    let subTitle = NSLocalizedString("Started", comment: "")
                    toast = Toast.default(image: UIImage(systemName: "clock.badge.fill")!, title: title, subtitle: subTitle, config: toastConfig)
                    toast.enableTapToClose()
                    toast.show()
                    
                } else { // 타이머가 이미 있으면 거절
                    makeVibration(type: .error)
                    
                    let title = NSLocalizedString("Endless already been set", comment: "")
                    toast = Toast.default(image: UIImage(systemName: "clock.badge.exclamationmark.fill")!, title: title, config: toastConfig)
                    toast.enableTapToClose()
                    toast.show()
                }
                
            case false:
                makeVibration(type: .success)
                viewModel.sendWithoutRepeat(text: meteorText)
            }
            
        } else { // 끝없이 취소
            meteorTextField.resignFirstResponder()
            endlessWorkingLabel.alpha = 0
            endlessTimerLabel.alpha = 0
            UserDefaults.standard.set(false, forKey: RepeatIdling)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            makeVibration(type: .medium)
            let title = NSLocalizedString("Endless", comment: "")
            let subTitle = NSLocalizedString("Canceled", comment: "")
            toast = Toast.default(image: UIImage(systemName: "clock.badge.xmark.fill")!, title: title, subtitle: subTitle, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
        }
    }
}

extension MeteorViewController {
    private func setLayout() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
        pageControl.numberOfPages = viewModel.noticeList.count
        
        endlessButton.isSelected = false
        datePicker.isEnabled = false
        datePicker.isHidden = true
        
        authView.layer.cornerRadius = 20
        authView.isHidden = true
        moveToSettingButton.layer.cornerRadius = 20
        moveToSettingButton.clipsToBounds = true
        
        [endlessWorkingLabel, endlessTimerLabel]
            .forEach { $0?.alpha = 0 }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
    }
    
    private func setTimer() {
        UserDefaults.standard.set(true, forKey: RepeatIdling)
        
        let triggeredDate = Date()
        let datePickerDuration = Int(datePicker.countDownDuration)
        var remainSecond = 0
        endlessTimerLabel.text = viewModel.secondsToString(seconds: datePickerDuration)

        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            let passSecond = Int(round(Date().timeIntervalSince(triggeredDate)))
            print(passSecond)
            
            if passSecond < datePickerDuration {
                remainSecond = datePickerDuration - passSecond
                self.endlessTimerLabel.text = viewModel.secondsToString(seconds: remainSecond)
            } else {
                remainSecond = datePickerDuration - (passSecond % datePickerDuration)
                self.endlessTimerLabel.text = viewModel.secondsToString(seconds: remainSecond)
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

extension MeteorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.noticeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCell.identifier, for: indexPath) as? NoticeCell else {
            return UICollectionViewCell()
        }
        cell.setLayout(notice: viewModel.noticeList[indexPath.row])
        return cell
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let page = Int(targetContentOffset.pointee.x / collectionView.bounds.width)
        pageControl.currentPage = page
    }
}

extension MeteorViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = collectionView.bounds.height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return .zero
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
            guard let interstitial = interstitial else { return print("Ad wasn't ready") }
            interstitial.present(fromRootViewController: self)
            currentAdIndex = 0
            
        } else if currentAdIndex > 50 { // exception: 상한선에 도달시 초기화
            currentAdIndex = 0
        }
        UserDefaults.standard.set(currentAdIndex, forKey: SavedAdIndex)
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
