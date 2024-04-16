//
//  ViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/13.
//

import UIKit
//import UserNotifications
import ActivityKit
//import FirebaseMessaging
import Toast
import Puller
import Alamofire

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
            getPushToStartToken()
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
        
//        UNUserNotificationCenter.current().delegate = self
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
//        UIApplication.shared.registerForRemoteNotifications()
        
//        Messaging.messaging().token { token, error in
//            if let error {
//                print("Error fetching FCM registration token: \(error)")
//            } else if let token = token {
//                print("FCM registration token: \(token)")
////                self.meteorTextLabel.text  = "Remote FCM registration token: \(token)"
//            }
//        }
    }
    
    func getPushToStartToken() {
        if #available(iOS 17.2, *) {
            Task {
                for await data in Activity<MeteorAttributes>.pushToStartTokenUpdates {
                    let token = data.hexadecimalString
                    print("🌊 Activity PushToStart Token: \(token)")
                    UserDefaults.standard.set(token, forKey: UserDefaultsKeys.deviceToken)
                }
            }
        }
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
        
//        let urlString = "https://api.sandbox.push.apple.com:443/3/device/806fcef757f914ed774b57ff82298b2631819688e92ede5821f0024e0a67d683a697db19b7d78a6dd02fbe260dbf7044042b56028349d60942f7967570387b592a1b32ee0907558cd5c232a7e6a73739"
//        
//        let deviceToken = "806fcef757f914ed774b57ff82298b2631819688e92ede5821f0024e0a67d683a697db19b7d78a6dd02fbe260dbf7044042b56028349d60942f7967570387b592a1b32ee0907558cd5c232a7e6a73739"
//        
//        let headers: HTTPHeaders = [
//            "authorization": "bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IlozR05KSzU2VlgifQ.eyJpc3MiOiJITTlKM0RHNU1UIiwiaWF0IjoxNzEzMjQwNzA3fQ.lcSv1Nmeu9PGUP9KhoScBxFjB5ishexEw3WOd09yXSSdEOzD6D-9lT8JogAQvyW4m6H0Xdrvy9Uk7OjWQEdOsQ",
//            "apns-topic": "com.soduma.Meteor.push-type.liveactivity",
//            "apns-priority": "5",
//            "apns-push-type": "liveactivity"
////            "apns-expiration": "0"
//        ]
//        
//        let body: [String: Any] = [
//            "aps": [
//                "timestamp": 1713240723,
//                "event": "start",
//                "content-state": [
//                    "liveText": "",
//                    "liveColor": 2,
//                    "hideContentOnLockScreen": true,
//                    "triggerDate": 1713240723
//                ],
//                "attributes-type": "MeteorAttributes",
//                "attributes": [
//                    "liveText": "",
//                    "liveColor": 2,
//                    "hideContentOnLockScreen": true,
//                    "triggerDate": 1713240723
//                ],
//                "alert": [
//                    "title": "A",
//                    "body": "B"
//                ]
//            ]
//        ]
//        
//        let payload = """
//{
//    "aps": {
//        "timestamp": 1713237010,
//        "event": "start",
//        "content-state": {
//            "liveText": "",
//            "liveColor": 0,
//            "hideContentOnLockScreen": true,
//            "triggerDate": 1713237010
//        },
//        "attributes-type": "MeteorAttributes",
//        "attributes": {
//            "liveText": "",
//            "liveColor": 0,
//            "hideContentOnLockScreen": true,
//            "triggerDate": 1713237010
//        },
//        "alert": {
//            "title": "A",
//            "body": "B"
//        }
//    }
//}
//"""
        
//        guard let url = URL(string: urlString) else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("bearer eyJhbGciOiJFUzI1NiIsImtpZCI6IlozR05KSzU2VlgifQ.eyJpc3MiOiJITTlKM0RHNU1UIiwiaWF0IjoxNzEzMjQzOTc4fQ.E2Rdi9NEX-QFTN3kIpRH34yJXt_tWR1Md2_DzuZ2f0VnHqUjfZvxL_-eO-MBPE7Nxv7NXzh5ft78QeoT-KBxdA", forHTTPHeaderField: "authorization")
//        request.setValue("com.soduma.Meteor.push-type.liveactivity", forHTTPHeaderField: "apns-topic")
//        request.setValue("10", forHTTPHeaderField: "apns-priority")
//        request.setValue("liveactivity", forHTTPHeaderField: "apns-push-type")
//        request.httpBody = payload.data(using: .utf8)
//        
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data else { return }
//            print(String(data: data, encoding: .utf8))
//        }
//        
//        task.resume()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.push(timestamp: Int(Date().timeIntervalSince1970.rounded()), liveColor: 1, isHide: true)
        }
        
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
    
    func push(timestamp: Int, liveColor: Int, isHide: Bool) {
        guard let p8Payload = FileParser.parse() else { return }
        do {
            let jsonWebToken = try JSONWebToken(keyID: FileParser.keyID, teamID: FileParser.teamID, p8Payload: p8Payload)
            print("🍓 jsonWebToken : \(jsonWebToken.token)")
            let authenticationToken = jsonWebToken.token
            let deviceToken = UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceToken) ?? ""
            let payload = 
"""
{
    "aps": {
        "timestamp": \(timestamp),
        "event": "start",
        "content-state": {
            "liveText": "",
            "liveColor": \(liveColor),
            "hideContentOnLockScreen": \(isHide),
            "triggerDate": \(timestamp)
        },
        "attributes-type": "MeteorAttributes",
        "attributes": {
            "liveText": "",
            "liveColor": \(liveColor),
            "hideContentOnLockScreen": \(isHide),
            "triggerDate": \(timestamp)
        },
        "alert": {
            "title": {
                "loc-key": "%@ is on an adventure!"
            },
            "body": {
                "loc-key": "%@ found a sword!",
                "loc-args": ["Live"]
            }
        }
    }
}
"""
            guard let request = APNSManager().urlRequest(
                authenticationToken: authenticationToken,
                deviceToken: deviceToken,
                payload: payload) else { return }
            
            let task = URLSession.shared.dataTask(with: request) { _, response, error in
                if let response {
                    print(response)
                } else if let error {
                    print(error.localizedDescription)
                }
            }
            task.resume()
            
        } catch {
            print(error.localizedDescription)
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
            if let activity = Activity<MeteorAttributes>.activities.first {
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

//extension MeteorViewController: UNUserNotificationCenterDelegate {}

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
