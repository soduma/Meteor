//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import SwiftUI
import MessageUI
import Puller

class SettingsViewController: UITableViewController {
    @IBOutlet weak var feedbackImageView: UIImageView!
    @IBOutlet weak var reviewImageView: UIImageView!
    @IBOutlet weak var versionImageView: UIImageView!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    @IBOutlet weak var hapticSwitch: UISwitch!
    @IBOutlet weak var timeSensitiveSwitch: UISwitch!
    
    @IBOutlet weak var alwaysOnLiveCell: UITableViewCell!
    @IBOutlet weak var alwaysOnLiveStackView: UIStackView!
    @IBOutlet weak var alwaysOnLiveisOnLabel: UILabel!
    @IBOutlet weak var alwaysOnLiveDescriptionLabel: UILabel!
    @IBOutlet weak var hideLiveContentSwitch: UISwitch!
    
    @IBOutlet weak var liveColorSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var keywordTextField: UITextField!
    @IBOutlet weak var refreshPhotoView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private let viewModel = SettingsViewModel()
    private let liveManager = LiveActivityManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        initialSeoul()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSwitchesState()
        viewModel.getFirebaseImageURL()
    }
    
    @IBAction func feedbackButtonTapped(_ sender: UIButton) {
        var reverseLast = ""
        if let last = UserDefaults.standard.string(forKey: UserDefaultsKeys.reviewVersionKey) {
            reverseLast = String(last.replacingOccurrences(of: ".", with: "").reversed())
        }
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             😄
                             
                             
                             
                             -------------------
                             
                             App Version : \(reverseLast). __\(SettingsViewModel.getCurrentVersion())
                             Device Model : \(UIDevice.modelName)
                             Device OS : \(UIDevice.current.systemVersion)
                             """
            
            composeViewController.setToRecipients(["dev.soduma@gmail.com"])
            composeViewController.setSubject("[Meteor] \(NSLocalizedString("Please enter the subject", comment: ""))")
            composeViewController.setMessageBody(bodyString, isHTML: false)
            present(composeViewController, animated: true)
        } else {
            let sendMailErrorAlert = UIAlertController(title: NSLocalizedString("mailHeader", comment: ""), message: NSLocalizedString("mailDescription", comment: ""), preferredStyle: .alert)
            
            let appStoreAction = UIAlertAction(title: NSLocalizedString("mailMove", comment: ""), style: .default) { _ in
                if let url = URL(string: "https://apps.apple.com/kr/app/mail/id1108187098"),
                    UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
            
            let copyAction = UIAlertAction(title: NSLocalizedString("mailCopy", comment: ""), style: .default) { _ in
                let email = "dev.soduma@gmail.com"
                UIPasteboard.general.string = email
                makeVibration(type: .success)
                ToastManager.makeToast(toast: &ToastManager.toast, title: email, imageName: "doc.on.doc")
            }
            
            let cancleAction = UIAlertAction(title: "취소", style: .cancel)
            
            [appStoreAction, copyAction, cancleAction]
                .forEach { sendMailErrorAlert.addAction($0) }
            present(sendMailErrorAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func reviewButtonTapped(_ sender: UIButton) {
        let url = "itms-apps://itunes.apple.com/app/1562989730"
        if let url = URL(string: url),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func lightModeSwitchTapped(_ sender: UISwitch) {
        darkModeSwitch.isOn = false
        viewModel.changeAppearance(lightMode: lightModeSwitch.isOn, darkMode: darkModeSwitch.isOn)
        
        setImageViewsBorder()
    }
    
    @IBAction func darkModeSwitchTapped(_ sender: UISwitch) {
        lightModeSwitch.isOn = false
        viewModel.changeAppearance(lightMode: lightModeSwitch.isOn, darkMode: darkModeSwitch.isOn)
        
        setImageViewsBorder()
    }
    
    @IBAction func hapticSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(hapticSwitch.isOn, forKey: UserDefaultsKeys.hapticStateKey)
    }
    
    @IBAction func timeSensitiveSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(timeSensitiveSwitch.isOn, forKey: UserDefaultsKeys.timeSensitiveStateKey)
    }
    
    @IBAction func hideLiveContentSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(hideLiveContentSwitch.isOn, forKey: UserDefaultsKeys.liveContentHideStateKey)
        
        showCustomAppReview()
        liveManager.rebootActivity()
    }
    
    @IBAction func liveColorSegmentedControlTapped(_ sender: UISegmentedControl) {
        makeVibration(type: .rigid)
        
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.liveColor = .red
        case 1:
            viewModel.liveColor = .black
        default:
            viewModel.liveColor = .clear
        }
        UserDefaults.standard.set(viewModel.liveColor.rawValue, forKey: UserDefaultsKeys.liveColorKey)
        
        showCustomAppReview()
        liveManager.rebootActivity()
    }
}

extension SettingsViewController {
    private func setLayout() {
        setImageViewsBorder()
        activityIndicatorView.isHidden = true
        keywordTextField.delegate = self
        
        hideLiveContentSwitch.isEnabled = viewModel.checkDeviceModel()
        
        if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.widgetDataKey) {
            imageView.image = UIImage(data: imageData)
        }
        
        let refreshPhotoGesture = UITapGestureRecognizer(target: self, action: #selector(refreshPhotoCellViewTapped))
        refreshPhotoView.addGestureRecognizer(refreshPhotoGesture)
        let alwaysOnLiveGesture = UITapGestureRecognizer(target: self, action: #selector(alwaysOnLiveCellViewTapped))
        alwaysOnLiveCell.addGestureRecognizer(alwaysOnLiveGesture)
        
        let currentLanguage = Bundle.main.preferredLocalizations[0]
        if  currentLanguage == "en" {
            alwaysOnLiveDescriptionLabel.isHidden = true
        }
    }
    
    private func initialSeoul() {
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.initialLaunchKey) == false {
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.initialLaunchKey)
            keywordTextField.text = "Seoul"
            viewModel.keywordText = "Seoul"
        }
    }
    
    private func setSwitchesState() {
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.lightStateKey)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.darkStateKey)
        
        hapticSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticStateKey)
        timeSensitiveSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.timeSensitiveStateKey)
        
        alwaysOnLiveisOnLabel.text = NSLocalizedString(UserDefaults.standard.bool(forKey: UserDefaultsKeys.alwaysOnLiveStateKey) ? "On" : "Off", comment: "")
        hideLiveContentSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveContentHideStateKey)
        
        liveColorSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey)
    }
    
    private func setImageViewsBorder() {
        [feedbackImageView, reviewImageView, versionImageView].forEach {
            $0?.layer.cornerRadius = 6
//            $0?.layer.borderColor = UIColor.systemGray5.withAlphaComponent(0.5).cgColor
            $0?.layer.borderColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 0.3).cgColor
            $0?.layer.borderWidth = 0.5
            $0?.clipsToBounds = true
        }
    }
    
    private func showCustomAppReview() {
        if viewModel.executeAppReviews() {
            let vc = MeteorReviewViewController()
            let pullerModel = PullerModel(animator: .default,
                                          detents: [.medium],
                                          isModalInPresentation: true,
                                          hasDynamicHeight: false,
                                          hasCircleCloseButton: false)
            presentAsPuller(vc, model: pullerModel)
        }
    }
    
    @objc private func refreshPhotoCellViewTapped() {
        keywordTextField.resignFirstResponder()
        makeVibration(type: .rigid)
        
        showCustomAppReview()
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        Task {
            guard let imageData = await viewModel.getNewImage() else { return }
            imageView.image = UIImage(data: imageData)
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    @objc private func alwaysOnLiveCellViewTapped() {
        let vc = UIHostingController(rootView: AlwaysOnLiveView())
        vc.title = NSLocalizedString("Always On Live", comment: "")
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordTextField.resignFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "Keyword" {
            textField.text = ""
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text == "Keyword" || textField.text == "" {
            textField.text = "Keyword"
            viewModel.keywordText = ""
            
        } else if textField.text != "",
                  let text = textField.text {
            let removeBlanks = text.replacingOccurrences(of: " ", with: "")
            textField.text = removeBlanks
            viewModel.keywordText = removeBlanks
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        dismiss(animated: true)
    }
}
