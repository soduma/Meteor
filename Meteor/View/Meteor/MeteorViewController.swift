//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications
//import GoogleMobileAds
//import AppTrackingTransparency
//import AdSupport
import Toast
import Puller

class MeteorViewController: UIViewController {
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var meteorTextLabel: UILabel!
    @IBOutlet var meteorTextLabelGesture: UITapGestureRecognizer!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var indicatorBackgroundView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        viewModel.checkAppearanceMode()
        
        // MARK: 앱 재실행 후 타이머 체크
        if viewModel.checkEndlessIdling() {
            endlessTimerLabel.isHidden = false
            
            let duration = UserDefaults.standard.integer(forKey: UserDefaultsKeys.endlessDurationKey)
            guard let savedEndlessDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.endlessTriggeredDateKey) as? Date else { return }
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: savedEndlessDate, duration: duration)
            setEndlessTimer(triggeredDate: savedEndlessDate, duration: duration)
        }
        
        // MARK: 리뷰 카운트 재설정
        let count = UserDefaults.standard.integer(forKey: UserDefaultsKeys.customAppReviewCountKey)
        if customReviewLimit - count < 10 {
            UserDefaults.standard.set(30, forKey: UserDefaultsKeys.customAppReviewCountKey)

        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if meteorText.isEmpty {
////            var attributes = AttributeContainer()
////            attributes.font = .systemFont(ofSize: 25, weight: .medium)
////            let localizeString = AttributedString(NSLocalizedString("Scribble here 👀", comment: ""), attributes: attributes)
//            meteorTextLabel.text = NSLocalizedString("Scribble here 👀", comment: "")
//            
//        } else {
//            meteorTextLabel.text = meteorText
//        }
        
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
        
//        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func moveToSettingButtonTapped(_ sender: UIButton) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
    
    @IBAction func meteorTextLabelTapped(_ sender: UITapGestureRecognizer) {
        // 알림 권한 확인
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            switch settings.authorizationStatus {
            case .authorized:
                makeVibration(type: .medium)
                
                DispatchQueue.main.async {
                    let vc = MeteorInputViewController(meteorText: self.viewModel.meteorText, labelPositionY: self.meteorTextLabel.frame.midY)
                    vc.modalPresentationStyle = .overCurrentContext
                    vc.delegate = self
                    self.present(vc, animated: false)
                }
                
            default:
                makeVibration(type: .error)
                
                DispatchQueue.main.async {
                    self.authView.isHidden = false
                    self.authViewBottom.constant = -self.view.bounds.height
                    
                    UIView.animate(withDuration: 0.4) {
                        self.authView.layoutIfNeeded()
                    }
                }
            }
        }
    }
    
    @IBAction func singleButtonTapped(_ sender: UIButton) {
        viewModel.meteorType = .single
        singleButton.isSelected = true
        
        headLabel.text = "METEOR :"
        headLabel.textColor = .red
        if viewModel.meteorText.isEmpty {
            meteorTextLabel.textColor = .placeholderText
        } else {
            meteorTextLabel.textColor = .label
        }
        
        meteorTextLabel.clipsToBounds = true
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
        if viewModel.meteorText.isEmpty {
            meteorTextLabel.textColor = .placeholderText
        } else {
            meteorTextLabel.textColor = .label
        }
        
        meteorTextLabel.clipsToBounds = true
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
        if viewModel.meteorText.isEmpty {
            meteorTextLabel.textColor = .placeholderText
        } else {
            meteorTextLabel.textColor = .white
        }
        
        meteorTextLabel.clipsToBounds = true
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
        if !viewModel.meteorText.isEmpty {
            meteorTextLabel.resignFirstResponder()
            makeVibration(type: .success)
            var duration = 0
//            showAD()
            
            switch viewModel.meteorType {
            case .single:
                viewModel.sendSingleMeteor(text: viewModel.meteorText)
                
            case .endless:
                makeToast(title: "Endless", subTitle: "Started", imageName: "clock.badge.fill")
                
                duration = Int(datePicker.countDownDuration)
                endlessTimerLabel.isHidden = false
                endlessTimerLabel.text = String.secondsToString(seconds: duration)
                stopButton.isHidden = false
                
                UserDefaults.standard.set(true, forKey: UserDefaultsKeys.endlessIdlingKey)
                viewModel.sendEndlessMeteor(text: viewModel.meteorText, duration: duration)
                setEndlessTimer(triggeredDate: Date(), duration: duration)
                
            case .live:
                makeToast(title: "Live", subTitle: "Started", imageName: "message.badge.filled.fill")
                
                stopButton.isHidden = false
                viewModel.startLiveActivity(text: viewModel.meteorText)
            }
            
#if RELEASE
            viewModel.sendToFirebase(type: viewModel.meteorType, text: meteorText, duration: duration)
#endif
            
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
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        sendButton.isEnabled = false
        stopButton.isHidden = true
        indicatorBackgroundView.isHidden = false
        activityIndicator.startAnimating()
        
        switch viewModel.meteorType {
        case .single:
            break
            
        case .endless:
            makeVibration(type: .medium)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.endlessIdlingKey)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.1) { [weak self] in
                guard let self else { return }
                makeVibration(type: .success)
                
                sendButton.isEnabled = true
                endlessTimerLabel.isHidden = true
                indicatorBackgroundView.isHidden = true
                activityIndicator.stopAnimating()
                makeToast(title: "Endless", subTitle: "Stopped", imageName: "clock.badge.xmark.fill")
            }
            
        case .live:
            makeVibration(type: .success)
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.liveIdlingKey)
            Task {
                await self.viewModel.endLiveActivity()
            }
            
            sendButton.isEnabled = true
            endlessTimerLabel.isHidden = true
            indicatorBackgroundView.isHidden = true
            activityIndicator.stopAnimating()
            makeToast(title: "Live", subTitle: "Stopped", imageName: "checkmark.message.fill")
        }
    }
}

extension MeteorViewController {
    private func setLayout() {
        liveBackgroundView.layer.cornerRadius = 24
        liveBackgroundView.clipsToBounds = true
        
        stopButton.layer.cornerRadius = 16
        stopButton.clipsToBounds = true
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.layer.cornerRadius = 20
        collectionView.clipsToBounds = true
        pageControl.numberOfPages = viewModel.noticeList.count
        
        authView.layer.cornerRadius = 20
        moveToSettingButton.layer.cornerRadius = 20
        moveToSettingButton.clipsToBounds = true
    }
    
    private func setEndlessTimer(triggeredDate: Date, duration: Int) {
        UserDefaults.standard.set(triggeredDate, forKey: UserDefaultsKeys.endlessTriggeredDateKey)
        
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
            let toastConfig = ToastConfiguration(autoHide: true, enablePanToClose: true, displayTime: 3)
            
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

extension MeteorViewController: MeteorTextDelegate {
    func setMeteorText(text: String) {
        viewModel.meteorText = text
        
        if text.isEmpty {
            meteorTextLabel.text = NSLocalizedString("Scribble here 👀", comment: "")
            meteorTextLabel.textColor = .placeholderText
        } else {
            let textList = text.components(separatedBy: "\n")
            if textList.count == 1 {
                meteorTextLabel.text = textList.first
            } else {
                guard let firstLineText = textList.first else { return }
                meteorTextLabel.text = "\(firstLineText)⋯"
            }
            
            switch viewModel.meteorType {
            case .single:
                meteorTextLabel.textColor = .label
            case .endless:
                meteorTextLabel.textColor = .label
            case .live:
                meteorTextLabel.textColor = .white
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
