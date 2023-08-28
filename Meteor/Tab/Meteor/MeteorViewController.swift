//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications
//import GoogleMobileAds
import AppTrackingTransparency
//import AdSupport
import Toast
import Puller

class MeteorViewController: UIViewController {
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var clearButton: UIButton!
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
    
    private let viewModel = MeteorViewModel()
    private var toast = Toast.text("")
    private var meteorText = ""
//    private var meteorSentCount = 0
    
    // MARK: ADMOB
//    private var interstitial: GADInterstitialAd?
//    var firebaseAdIndex = 0
//    var currentAdIndex = 0
//
//    #if DEBUG
//    var adUnitID1 = "ca-app-pub-3940256099942544/4411468910" // 테스트 1
//    var adUnitID2 = "ca-app-pub-3940256099942544/4411468910" // 테스트 2
//    #else
//    var adUnitID1 = "ca-app-pub-1960781437106390/8071718444" // 전면 1
//    var adUnitID2 = "ca-app-pub-1960781437106390/9294984986" // 전면 2
//    #endif
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.initialAppLaunchSettings()
        
        if let window = UIApplication.shared.windows.first {
            viewModel.checkApperanceMode(window: window)
        }
        
//        currentAdIndex = UserDefaults.standard.integer(forKey: savedAdIndexKey)
//        viewModel.getFirebaseAdIndex { [weak self] value in
//            self?.firebaseAdIndex = value
//        }
        
//        meteorSentCount = UserDefaults.standard.integer(forKey: meteorSentCountKey)
        
        // MARK: 앱 종료 후 타이머 유무 체크
        if viewModel.checkEndlessIdling() {
            endlessTimerLabel.isHidden = false
            
            let seconds = UserDefaults.standard.integer(forKey: endlessDurationKey)
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
        
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func textFieldInputted(_ sender: UITextField) {
//        clearButton.isHidden = !textField.hasText
        clearButton.alpha = textField.hasText ? 1 : 0
        
        // MARK: 알림 권한 다시 확인
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

        UIView.animate(withDuration: 0.2) {
            self.clearButton.alpha = 0
        }
    }
    
    @IBAction func timePickerChanged(_ sender: UIDatePicker) {
        print(datePicker.countDownDuration)
    }
    
    @IBAction func moveToSettingButtonTapped(_ sender: UIButton) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: UIButton) {
        textField.text = ""
        clearButton.alpha = 0
    }
    
    @IBAction func singleButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .single
        singleButton.isSelected = true
        
        headLabel.text = "METEOR :"
        headLabel.textColor = .red
        textField.textColor = .label
        textField.tintColor = .systemRed
        datePicker.isHidden = true
        
        endlessButton.isSelected = false
        liveButton.isSelected = false
        liveBackgroundView.alpha = 0
        stopButton.isHidden = true
        
        makeVibration(type: .rigid)
    }
    
    @IBAction func endlessButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .endless
        endlessButton.isSelected = true
        
        headLabel.text = "ENDLESS\nMETEOR :"
        headLabel.textColor = .red
        textField.textColor = .label
        textField.tintColor = .systemRed
        datePicker.isHidden = false
        
        singleButton.isSelected = false
        liveButton.isSelected = false
        liveBackgroundView.alpha = 0
        
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
        textField.textColor = .white
        textField.tintColor = .yellow
        datePicker.isHidden = true
        
        singleButton.isSelected = false
        endlessButton.isSelected = false
        
        UIView.animate(withDuration: 0.2) {
            self.headLabel.textColor = .white
            self.liveBackgroundView.alpha = 1
        }
        
        if viewModel.checkLiveIdling() {
            stopButton.isHidden = false
        } else {
            stopButton.isHidden = true
        }
        
        makeVibration(type: .rigid)
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        if let text = textField.text, !text.isEmpty {
            textField.resignFirstResponder()
//            showAD()
            
            switch viewModel.meteorType {
            case .single:
                makeVibration(type: .success)
                viewModel.sendSingleMeteor(text: meteorText)
                
            case .endless:
                stopButton.isHidden = false
                let duration = Int(datePicker.countDownDuration)
                endlessTimerLabel.isHidden = false
                endlessTimerLabel.text = String.secondsToString(seconds: duration)
                
                makeVibration(type: .success)
                makeToast(title: "Endless", subTitle: "Started", imageName: "clock.badge.fill")
                                
                UserDefaults.standard.set(true, forKey: endlessIdlingKey)
                viewModel.sendEndlessMeteor(text: meteorText, duration: duration)
                setEndlessTimer(triggeredDate: Date(), duration: duration)
                
            case .live:
                stopButton.isHidden = false
                
                makeVibration(type: .success)
                makeToast(title: "Live", subTitle: "Started", imageName: "message.badge.filled.fill")
                
                viewModel.startLiveActivity(text: meteorText)
            }
            
            // MARK: 앱 리뷰
            SettingViewModel().checkSystemAppReview()
            if SettingViewModel().checkCustomAppReview() {
                let vc = MeteorReviewViewController()
                let pullerModel = PullerModel(animator: .default,
                                              detents: [.medium],
                                              cornerRadius: 50,
                                              isModalInPresentation: true,
                                              hasDynamicHeight: false,
                                              hasCircleCloseButton: false)
                presentAsPuller(vc, model: pullerModel)
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
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
            makeToast(title: "Endless", subTitle: "Stopped", imageName: "clock.badge.xmark.fill")
            
            UserDefaults.standard.set(false, forKey: endlessIdlingKey)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
        case .live:
            makeVibration(type: .medium)
            makeToast(title: "Live", subTitle: "Stopped", imageName: "checkmark.message.fill")
            
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
    
    private func makeToast(title: String, subTitle: String, imageName: String) {
        toast.close()
        
        if subTitle.isEmpty {
            let title = NSLocalizedString(title, comment: "")
            toast = Toast.text(title)
            toast.enableTapToClose()
            toast.show()
        } else {
            let toastConfig = ToastConfiguration(autoHide: true, enablePanToClose: false, displayTime: 3)
            
            let title = NSLocalizedString(title, comment: "")
            let subTitle = NSLocalizedString(subTitle, comment: "")
            toast = Toast.default(image: UIImage(systemName: imageName)!, title: title, subtitle: subTitle, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            if textField.hasText {
                self.clearButton.alpha = 1
            } else {
                self.clearButton.alpha = 0
            }
        }
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
//extension MeteorViewController: GADFullScreenContentDelegate {
//    private func showAD() {
//        currentAdIndex += 1
//
//        if currentAdIndex >= firebaseAdIndex {
//            guard let interstitial = interstitial else { return print("Ad wasn't ready") }
//            interstitial.present(fromRootViewController: self)
//            currentAdIndex = 0
//
//        } else if currentAdIndex > 50 { // exception: 상한선에 도달시 초기화
//            currentAdIndex = 0
//        }
//        UserDefaults.standard.set(currentAdIndex, forKey: savedAdIndexKey)
//    }
//
//    private func firstLoadAd() {
//        let request = GADRequest()
//        GADInterstitialAd.load(withAdUnitID: adUnitID1,
//                               request: request,
//                               completionHandler: { [weak self] ad, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                return
//            }
//            interstitial = ad
//            interstitial?.fullScreenContentDelegate = self
//        })
//    }
//
//    /// Tells the delegate that the ad failed to present full screen content.
//    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
//        print("Ad did fail to present full screen content.")
//    }
//
//    /// Tells the delegate that the ad will present full screen content.
//    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        print("Ad will present full screen content.")
//    }
//
//    /// Tells the delegate that the ad dismissed full screen content.
//    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
//        let request2 = GADRequest()
//        GADInterstitialAd.load(withAdUnitID: adUnitID2,
//                               request: request2,
//                               completionHandler: { [weak self] ad, error in
//            guard let self = self else { return }
//            if let error = error {
//                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
//                return
//            }
//            interstitial = ad
//            interstitial?.fullScreenContentDelegate = self
//        })
//        print("Ad did dismiss full screen content.")
//    }
//}
