//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController {
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var hapticSwitch: UISwitch!
    @IBOutlet weak var lockScreenSwitch: UISwitch!
    @IBOutlet weak var liveColorSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var refreshPhotoView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var starRateView: UIVisualEffectView!
    @IBOutlet weak var rateHeaderLabel: UILabel!
    @IBOutlet weak var rateTextLabel: UILabel!
    @IBOutlet weak var rateCloseButton: UIButton!
    @IBOutlet weak var rateSubmitButton: UIButton!
    @IBOutlet weak var keywordTextField: UITextField!
    
    private let viewModel = SettingsViewModel()
    var keywordText = ""
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setSwitchesState()
        viewModel.getFirebaseImageURL()
    }
    
    private func setLayout() {
        activityIndicatorView.isHidden = true
        keywordTextField.delegate = self
        
        lockScreenSwitch.isEnabled = viewModel.checkDeviceModel()
        
        if let imageData = UserDefaults.standard.data(forKey: UserDefaultsKeys.widgetDataKey) {
            imageView.image = UIImage(data: imageData)
        }
        
        let refreshGesture = UITapGestureRecognizer(target: self, action: #selector(refreshViewTapped))
        refreshPhotoView.addGestureRecognizer(refreshGesture)
        
        rateSubmitButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Submit", comment: "")), for: .normal)
    }
    
    private func setSwitchesState() {
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.lightStateKey)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.darkStateKey)
        hapticSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.hapticStateKey)
        lockScreenSwitch.isOn = UserDefaults.standard.bool(forKey: UserDefaultsKeys.lockScreenStateKey)
        liveColorSegmentedControl.selectedSegmentIndex = UserDefaults.standard.integer(forKey: UserDefaultsKeys.liveColorKey)
    }
    
    @objc private func refreshViewTapped() {
        keywordTextField.resignFirstResponder()
        makeVibration(type: .rigid)
        
        starRateView.isHidden = !viewModel.executeAppReviews()
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        Task {
            guard let imageData = await viewModel.getNewImage(keyword: keywordText) else { return }
            imageView.image = UIImage(data: imageData)
            activityIndicatorView.isHidden = true
            activityIndicatorView.stopAnimating()
        }
    }
    
    @IBAction func mailButtonTapped(_ sender: UIButton) {
        if MFMailComposeViewController.canSendMail() {
            let composeViewController = MFMailComposeViewController()
            composeViewController.mailComposeDelegate = self
            
            let bodyString = """
                             😄
                             
                             
                             
                             -------------------
                             
                             App Version : \(viewModel.getCurrentVersion())
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
    }
    
    @IBAction func darkModeSwitchTapped(_ sender: UISwitch) {
        lightModeSwitch.isOn = false
        viewModel.changeAppearance(lightMode: lightModeSwitch.isOn, darkMode: darkModeSwitch.isOn)
    }
    
    @IBAction func hapticSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(hapticSwitch.isOn, forKey: UserDefaultsKeys.hapticStateKey)
    }
    
    @IBAction func lockScreenSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(lockScreenSwitch.isOn, forKey: UserDefaultsKeys.lockScreenStateKey)
        restartLiveActivity()
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
        restartLiveActivity()
    }
    
    private func restartLiveActivity() {
        _ = viewModel.executeAppReviews()
        
        Task {
            let meteorViewModel = MeteorViewModel()
            await meteorViewModel.endLiveActivity()
            
            let liveText = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? ""
            _ = meteorViewModel.startLiveActivity(text: liveText)
        }
    }
    
    @IBAction func rateSubmitTapped(_ sender: UIButton) {
        let url = "https://apps.apple.com/app/id1562989730?action=write-review"
        guard let writeReviewURL = URL(string: url) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
        starRateView.isHidden = true
        UserDefaults.standard.set(viewModel.getCurrentVersion(), forKey: UserDefaultsKeys.lastVersionKey)
    }
    
    @IBAction func rateCloseTapped(_ sender: UIButton) {
        starRateView.isHidden = true
        UserDefaults.standard.set(0, forKey: UserDefaultsKeys.customAppReviewCountKey)
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
            keywordText = ""
            
        } else if textField.text != "",
                  let text = textField.text {
            let removeBlanks = text.replacingOccurrences(of: " ", with: "")
            textField.text = removeBlanks
            keywordText = removeBlanks
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: (any Error)?) {
        dismiss(animated: true)
    }
}
