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
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var endlessButton: UIButton!
    @IBOutlet weak var liveButton: UIButton!
    @IBOutlet weak var liveBackgroundView: UIView!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var endlessTimerLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet weak var authView: UIView!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    @IBOutlet weak var moveToSettingButton: UIButton!
    
    let viewModel = MeteorViewModel()
    var meteorText = ""
    var toast = Toast.text("")
    let toastConfig = ToastConfiguration(autoHide: true, enablePanToClose: false, displayTime: 3)
    
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
        viewModel.checkIntialAppLaunch()
        
        if let window = UIApplication.shared.windows.first {
            viewModel.checkApperanceMode(window: window)
        }
        
        currentAdIndex = UserDefaults.standard.integer(forKey: savedAdIndexKey)
        viewModel.getFirebaseAdIndex { [weak self] value in
            self?.firebaseAdIndex = value
        }
        
        // 앱 종료 후 타이머 유무 체크
        if viewModel.checkEndlessIdling() {
            endlessTimerLabel.isHidden = false
            
            let seconds = UserDefaults.standard.integer(forKey: endlessSecondsKey)
            guard let savedEndessDate = UserDefaults.standard.object(forKey: endlessTriggeredDateKey) as? Date else { return }
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: savedEndessDate, duration: seconds)
            setEndlessTimer(triggeredDate: savedEndessDate, duration: seconds)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
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
    
    @IBAction func textFieldInputted(_ sender: UITextField) {
        // 알림 권한 다시 확인
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            if settings.authorizationStatus == .denied {
                print("Push notification is NOT enabled")
                
                DispatchQueue.main.async {
                    self.authView.isHidden = false
                    self.textField.resignFirstResponder()
                    self.authViewBottom.constant = -self.view.bounds.height
                    self.textField.text = ""
                    
                    UIView.animate(withDuration: 0.5, animations: {
                        self.authView.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    @IBAction func singleButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .single
        singleButton.isSelected = true
        
        headLabel.text = "METEOR :"
        headLabel.textColor = .red
        datePicker.isHidden = true
        
        liveBackgroundView.isHidden = true
        endlessButton.isSelected = false
        liveButton.isSelected = false
        textField.textColor = .label
        
        makeVibration(type: .rigid)
    }
    
    @IBAction func endlessButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .endless
        endlessButton.isSelected = true
        
        headLabel.text = "ENDLESS \nMETEOR :"
        headLabel.textColor = .red
        datePicker.isHidden = false
        
        liveBackgroundView.isHidden = true
        singleButton.isSelected = false
        liveButton.isSelected = false
        textField.textColor = .label
        
        if viewModel.checkEndlessIdling() {
            stopButton.isHidden = false
        } else {
            stopButton.isHidden = true
        }
        
        makeVibration(type: .rigid)
    }
    
    @IBAction func liveButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .live
        liveButton.isSelected = true
        
        headLabel.text = "METEOR"
        headLabel.textColor = .white
        datePicker.isHidden = true
        
        liveBackgroundView.isHidden = false
        singleButton.isSelected = false
        endlessButton.isSelected = false
        textField.textColor = .white
        
        if viewModel.checkLiveIdling() {
            stopButton.isHidden = false
        } else {
            stopButton.isHidden = true
        }
        
        makeVibration(type: .rigid)
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        print(datePicker.countDownDuration)
    }
    
    @IBAction func moveToSettingButtonTapped(_ sender: UIButton) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        toast.close()
        
        if let text = textField.text, !text.isEmpty {
            textField.resignFirstResponder()
            showAD()
            
            switch viewModel.meteorType {
            case .single:
                makeVibration(type: .success)
                viewModel.sendSingleMeteor(text: meteorText)
                
            case .endless:
                stopButton.isHidden = false
                
                makeVibration(type: .success)
                UserDefaults.standard.set(true, forKey: endlessIdlingKey)
                
                let duration = Int(datePicker.countDownDuration)
                endlessTimerLabel.isHidden = false
                endlessTimerLabel.text = String.secondsToString(seconds: duration)
                
                viewModel.sendEndlessMeteor(text: meteorText, duration: duration)
                setEndlessTimer(triggeredDate: Date(), duration: duration)
                
                let title = NSLocalizedString("Endless", comment: "")
                let subTitle = NSLocalizedString("Started", comment: "")
                toast = Toast.default(image: UIImage(systemName: "clock.badge.fill")!, title: title, subtitle: subTitle, config: toastConfig)
                toast.enableTapToClose()
                toast.show()
                
            case .live:
                stopButton.isHidden = false
                
                makeVibration(type: .success)
                viewModel.startLiveActivity(text: meteorText)
                
                let title = NSLocalizedString("Live", comment: "")
                let subTitle = NSLocalizedString("Started", comment: "")
                toast = Toast.default(image: UIImage(systemName: "message.badge.filled.fill")!, title: title, subtitle: subTitle, config: toastConfig)
                toast.enableTapToClose()
                toast.show()
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        toast.close()
        stopButton.isHidden = true
        sendButton.isEnabled = false
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.sendButton.isEnabled = true
        }
        
        switch viewModel.meteorType {
        case .single:
            return
            
        case .endless:
            endlessTimerLabel.isHidden = true
            
            makeVibration(type: .medium)
            let title = NSLocalizedString("Endless", comment: "")
            let subTitle = NSLocalizedString("Stopped", comment: "")
            toast = Toast.default(image: UIImage(systemName: "clock.badge.xmark.fill")!, title: title, subtitle: subTitle, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
            
            UserDefaults.standard.set(false, forKey: endlessIdlingKey)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
        case .live:
            makeVibration(type: .medium)
            let title = NSLocalizedString("Live", comment: "")
            let subTitle = NSLocalizedString("Stopped", comment: "")
            toast = Toast.default(image: UIImage(systemName: "checkmark.message.fill")!, title: title, subtitle: subTitle, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
            
            Task {
                UserDefaults.standard.set(false, forKey: liveIdlingKey)
                await self.viewModel.endLiveActivity()
            }
        }
    }
}

extension MeteorViewController {
    private func setLayout() {
        liveBackgroundView.layer.cornerRadius = 24
        liveBackgroundView.clipsToBounds = true
        
        stopButton.layer.cornerRadius = 16
        stopButton.clipsToBounds = true
        
        textField.delegate = self
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
        pageControl.numberOfPages = viewModel.noticeList.count
        
        authView.layer.cornerRadius = 20
        authView.isHidden = true
        moveToSettingButton.layer.cornerRadius = 20
        moveToSettingButton.clipsToBounds = true
        
        endlessTimerLabel.isHidden = true
    }
    
    private func setEndlessTimer(triggeredDate: Date, duration: Int) {
        UserDefaults.standard.set(triggeredDate, forKey: endlessTriggeredDateKey)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self = self else { return }
            
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: triggeredDate, duration: duration)
            
            // MARK: 여기서 타이머 중지
            if viewModel.checkEndlessIdling() == false {
                timer.invalidate()
                print("timer invalidate")
            }
        }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
    }
    
    @objc private func checkNetworkConnection() {
        if Reachability.isConnectedToNetwork() == false {
            sendButton.isEnabled = false
            print("Internet Connection not Available!")
        }
    }
    
    @objc private func checkNotificationAuth() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            if settings.authorizationStatus == .authorized {
                print("Push notification is enabled")
                self?.prepareAuthView()
            }
        }
    }
}

extension MeteorViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            meteorText = text
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
        UserDefaults.standard.set(currentAdIndex, forKey: savedAdIndexKey)
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
