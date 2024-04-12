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
import ActivityKit

class MeteorViewController: UIViewController {
    @IBOutlet weak var headLabel: UILabel!
    @IBOutlet weak var meteorTextLabel: UILabel!
    @IBOutlet var liveBackgroundViewTapGesture: UITapGestureRecognizer!
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
    @IBOutlet weak var authCloseButton: UIButton!
    @IBOutlet weak var authViewBottom: NSLayoutConstraint!
    @IBOutlet weak var moveToSettingButton: UIButton!
    
    private let viewModel = MeteorViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        checkTimerRunning()
        
        Task {
            await viewModel.initialAppLaunchSettings()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        checkStopButtonNeedToHide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(removeAuthViewAfterAllowAuthorization),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkStopButtonNeedToHide),
                                               name: UIApplication.didBecomeActiveNotification,
                                               object: nil)
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
        UNUserNotificationCenter.current().delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func liveBackgroundViewTapped(_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            makeVibration(type: .medium)
            
            let vc = MeteorInputViewController(meteorText: viewModel.meteorText, labelPositionY: meteorTextLabel.frame.midY)
            vc.modalPresentationStyle = .overCurrentContext
            vc.delegate = self
            present(vc, animated: false)
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
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] setting in
            guard let self else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                
                switch setting.authorizationStatus {
                case .authorized:
                    
                    guard viewModel.meteorText.isEmpty == false else { return }
                    var endlessDuration = 0
                    
                    switch viewModel.meteorType {
                    case .single:
                        viewModel.sendSingleMeteor(text: viewModel.meteorText)
                        makeVibration(type: .success)
                        
                    case .endless:
                        stopButton.isHidden = false
                        ToastManager.makeToast(toast: &ToastManager.toast, title: "Endless", subTitle: "Started", imageName: "clock.badge.fill")
                        makeVibration(type: .success)
                        
                        endlessDuration = Int(datePicker.countDownDuration)
                        endlessTimerLabel.isHidden = false
                        endlessTimerLabel.text = String.secondsToString(seconds: endlessDuration)
                        setEndlessTimer(triggeredDate: Date(), duration: endlessDuration)
                        viewModel.sendEndlessMeteor(text: viewModel.meteorText, duration: endlessDuration)
                        
                        UserDefaults.standard.set(true, forKey: UserDefaultsKeys.endlessIdlingKey)
                        
                    case .live:
                        if viewModel.startLiveActivity(text: viewModel.meteorText) {
                            stopButton.isHidden = false
                            ToastManager.makeToast(toast: &ToastManager.toast, title: "Live", subTitle: "Started", imageName: "message.badge.filled.fill")
                            makeVibration(type: .success)
                        } else {
                            showAuthView()
                            makeVibration(type: .error)
                        }
                    }
                    
                    viewModel.saveHistory()
                    viewModel.sendToFirebase(type: viewModel.meteorType, text: viewModel.meteorText, duration: endlessDuration)
                    showCustomAppReview()
                    
                default:
                    makeVibration(type: .error)
                    showAuthView()
                }
            }
        }
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        sendButton.isEnabled = false
        stopButton.isHidden = true
        
        switch viewModel.meteorType {
        case .single:
            break
            
        case .endless:
            makeVibration(type: .medium)
            activityIndicator.startAnimating()
            indicatorBackgroundView.isHidden = false
            endlessTimerLabel.attributedText = endlessTimerLabel.text?.strikeThrough()
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.1) { [weak self] in
                guard let self else { return }
                makeVibration(type: .success)
                ToastManager.makeToast(toast: &ToastManager.toast, title: "Endless", subTitle: "Stopped", imageName: "clock.badge.xmark.fill")
                
                sendButton.isEnabled = true
                endlessTimerLabel.isHidden = true
                indicatorBackgroundView.isHidden = true
                activityIndicator.stopAnimating()
                endlessTimerLabel.attributedText = endlessTimerLabel.text?.removeStrike()
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.endlessIdlingKey)
            }
            
        case .live:
            makeVibration(type: .success)
            ToastManager.makeToast(toast: &ToastManager.toast, title: "Live", subTitle: "Stopped", imageName: "checkmark.message.fill")
            
            Task {
                await viewModel.endLiveActivity()
            }
            
            sendButton.isEnabled = true
        }
    }
    
    @IBAction func authCloseButtonTapped(_ sender: UIButton) {
        authView.isHidden = true
        authViewBottom.constant = view.bounds.height
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
            liveBackgroundView.backgroundColor = .clear
            stopButton.isHidden = true
            
        case .endless:
            endlessButton.isSelected = true
            
            headLabel.text = "ENDLESS\nMETEOR :"
            headLabel.textColor = .red
            meteorTextLabel.textColor = viewModel.meteorText.isEmpty ? .placeholderText : .label
            
            singleButton.isSelected = false
            datePicker.isHidden = false
            liveButton.isSelected = false
            liveBackgroundView.backgroundColor = .clear
            stopButton.isHidden = !viewModel.isEndlessIdling()
            
        case .live:
            liveButton.isSelected = true
            
            meteorTextLabel.textColor = viewModel.meteorText.isEmpty ? .placeholderText : .white
            
            singleButton.isSelected = false
            endlessButton.isSelected = false
            datePicker.isHidden = true
            stopButton.isHidden = !viewModel.isLiveActivityAlive()
            
            UIView.animate(withDuration: 0.2) {
                self.headLabel.text = "METEOR"
                self.headLabel.textColor = .white
                self.liveBackgroundView.backgroundColor = .systemRed
            }
        }
    }
    
    /// 앱 재실행 후 타이머 체크
    private func checkTimerRunning() {
        if viewModel.isEndlessIdling() {
            endlessTimerLabel.isHidden = false
            
            guard let savedEndlessDate = UserDefaults.standard.object(forKey: UserDefaultsKeys.endlessTriggeredDateKey) as? Date else { return }
            let duration = UserDefaults.standard.integer(forKey: UserDefaultsKeys.endlessDurationKey)
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: savedEndlessDate, duration: duration)
            setEndlessTimer(triggeredDate: savedEndlessDate, duration: duration)
        }
    }
    
    private func setEndlessTimer(triggeredDate: Date, duration: Int) {
        UserDefaults.standard.set(triggeredDate, forKey: UserDefaultsKeys.endlessTriggeredDateKey)
        
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            guard let self else { return }
            endlessTimerLabel.text = viewModel.setEndlessTimerLabel(triggeredDate: triggeredDate, duration: duration)
            
            // MARK: - 여기서 타이머 중지
            if viewModel.isEndlessIdling() == false {
                timer.invalidate()
                print("❎ timer invalidate")
            }
            // MARK: -
        }
    }
    
    private func showCustomAppReview() {
        if SettingsViewModel().executeAppReviews() {
            let vc = MeteorReviewViewController()
            let pullerModel = PullerModel(animator: .default,
                                          detents: [.medium],
                                          isModalInPresentation: true,
                                          hasDynamicHeight: false,
                                          hasCircleCloseButton: false)
            presentAsPuller(vc, model: pullerModel)
        }
    }
    
    private func showAuthView() {
        DispatchQueue.main.async {
            self.authView.isHidden = false
            self.authViewBottom.constant = -self.view.bounds.height
            
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
                self.authView.layoutIfNeeded()
            }
        }
    }
    
    @objc private func removeAuthViewAfterAllowAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] setting in
            DispatchQueue.main.async {
                guard let self else { return }
                if setting.authorizationStatus == .authorized {
                    self.authViewBottom.constant = self.view.bounds.height
                }
            }
        }
    }
    
    @objc private func checkStopButtonNeedToHide() {
        switch viewModel.meteorType {
        case .single:
            stopButton.isHidden = true
        case .endless:
            stopButton.isHidden = !viewModel.isEndlessIdling()
        case .live:
            if let activity = Activity<MeteorWidgetAttributes>.activities.first {
                if activity.activityState == .active || activity.activityState == .ended {
                    stopButton.isHidden = false
                }
            } else {
                stopButton.isHidden = true
            }
        }
    }
}

extension MeteorViewController: MeteorInputDelegate {
    func updateMeteorTextLabelUI(text: String) {
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

extension MeteorViewController: UNUserNotificationCenterDelegate {
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
