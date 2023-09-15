//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
import UserNotifications
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.initialAppLaunchSettings()
        viewModel.checkAppearanceMode()
        
        // MARK: 앱 재실행 후 타이머 체크
        if viewModel.checkEndlessIdling() {
            endlessTimerLabel.isHidden = false
            
            guard let savedEndlessDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.endlessTriggeredDateKey) as? Date else { return }
            let duration = UserDefaults.standard.integer(forKey: UserDefaultsKeys.endlessDurationKey)
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
        
        if !Reachability.isConnectedToNetwork() {
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func meteorTextLabelTapped(_ sender: UITapGestureRecognizer) {
        // 알림 권한 확인
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            guard let self else { return }
            
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
        makeVibration(type: .rigid)
        viewModel.meteorType = .single
        updateStackButtonUI(type: .single)
    }
    
    @IBAction func endlessButtonTapped(_ sender: UIButton) {
        makeVibration(type: .rigid)
        viewModel.meteorType = .endless
        updateStackButtonUI(type: .endless)
    }
    
    @IBAction func liveButtonTapped(_ sender: UIButton) {
        makeVibration(type: .rigid)
        viewModel.meteorType = .live
        updateStackButtonUI(type: .live)
        
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard !viewModel.meteorText.isEmpty else { return }
        meteorTextLabel.resignFirstResponder()
        makeVibration(type: .success)
        var endlessDuration = 0
        
        switch viewModel.meteorType {
        case .single:
            viewModel.sendSingleMeteor(text: viewModel.meteorText)
            
        case .endless:
            makeToast(toast: &toast, title: "Endless", subTitle: "Started", imageName: "clock.badge.fill")
            
            endlessDuration = Int(datePicker.countDownDuration)
            endlessTimerLabel.isHidden = false
            endlessTimerLabel.text = String.secondsToString(seconds: endlessDuration)
            stopButton.isHidden = false
            
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.endlessIdlingKey)
            viewModel.sendEndlessMeteor(text: viewModel.meteorText, duration: endlessDuration)
            setEndlessTimer(triggeredDate: Date(), duration: endlessDuration)
            
        case .live:
            makeToast(toast: &toast, title: "Live", subTitle: "Started", imageName: "message.badge.filled.fill")
            
            stopButton.isHidden = false
            viewModel.startLiveActivity(text: viewModel.meteorText)
        }
        
        viewModel.sendToFirebase(type: viewModel.meteorType, text: viewModel.meteorText, duration: endlessDuration)
        
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
                makeToast(toast: &toast, title: "Endless", subTitle: "Stopped", imageName: "clock.badge.xmark.fill")
                
                sendButton.isEnabled = true
                endlessTimerLabel.isHidden = true
                indicatorBackgroundView.isHidden = true
                activityIndicator.stopAnimating()
            }
            
        case .live:
            makeVibration(type: .success)
            makeToast(toast: &toast, title: "Live", subTitle: "Stopped", imageName: "checkmark.message.fill")
            UserDefaults.standard.set(false, forKey: UserDefaultsKeys.liveIdlingKey)
            Task {
                await self.viewModel.endLiveActivity()
            }
            
            sendButton.isEnabled = true
            endlessTimerLabel.isHidden = true
            indicatorBackgroundView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    @IBAction func moveToSettingButtonTapped(_ sender: UIButton) {
        if let settingURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingURL)
        }
    }
}

extension MeteorViewController {
    private func setLayout() {
        liveBackgroundView.layer.cornerRadius = 24
        liveBackgroundView.clipsToBounds = true
        meteorTextLabel.clipsToBounds = true
        
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
    
    private func updateStackButtonUI(type: MeteorType) {
        switch type {
        case .single:
            singleButton.isSelected = true
            
            headLabel.text = "METEOR :"
            headLabel.textColor = .red
            meteorTextLabel.textColor = viewModel.meteorText.isEmpty ? .placeholderText : .label
            
            endlessButton.isSelected = false
            datePicker.isHidden = true
            liveButton.isSelected = false
            liveBackgroundView.alpha = 0
            stopButton.isHidden = true
            
        case .endless:
            endlessButton.isSelected = true
            
            headLabel.text = "ENDLESS\nMETEOR :"
            headLabel.textColor = .red
            meteorTextLabel.textColor = viewModel.meteorText.isEmpty ? .placeholderText : .label
            
            singleButton.isSelected = false
            datePicker.isHidden = false
            liveButton.isSelected = false
            liveBackgroundView.alpha = 0
            stopButton.isHidden = viewModel.checkEndlessIdling() ? false : true
            
        case .live:
            liveButton.isSelected = true
            
            headLabel.text = "METEOR"
            meteorTextLabel.textColor = viewModel.meteorText.isEmpty ? .placeholderText : .white
            
            singleButton.isSelected = false
            endlessButton.isSelected = false
            datePicker.isHidden = true
            stopButton.isHidden = viewModel.checkLiveIdling() ? false : true
            
            UIView.animate(withDuration: 0.2) {
                self.headLabel.textColor = .white
                self.liveBackgroundView.alpha = 1
            }
        }
    }
    
    private func setEndlessTimer(triggeredDate: Date, duration: Int) {
        UserDefaults.standard.set(triggeredDate, forKey: UserDefaultsKeys.endlessTriggeredDateKey)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: triggeredDate, duration: duration)
            
            // MARK: 여기서 타이머 중지
            if viewModel.checkEndlessIdling() == false {
                timer.invalidate()
                print("❎ timer invalidate")
            }
        }
    }
    
    private func prepareAuthView() {
        DispatchQueue.main.async {
            self.authViewBottom.constant = self.view.bounds.height
        }
    }
    
    @objc private func checkNetworkConnection() {
        if !Reachability.isConnectedToNetwork() {
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

extension MeteorViewController: MeteorInputDelegate {
    func setInputtedText(text: String) {
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

extension MeteorViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        [.banner, .list, .sound, .badge]
    }
}

extension MeteorViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.noticeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NoticeCell.identifier, for: indexPath) as? NoticeCell else {
            return UICollectionViewCell() }
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
