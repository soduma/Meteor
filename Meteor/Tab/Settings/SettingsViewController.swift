//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var hapticSwitch: UISwitch!
    @IBOutlet weak var lockScreenSwitch: UISwitch!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var refreshPhotoView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var starRateView: UIVisualEffectView!
    @IBOutlet weak var rateHeaderLabel: UILabel!
    @IBOutlet weak var rateTextLabel: UILabel!
    @IBOutlet weak var rateCloseButton: UIButton!
    @IBOutlet weak var rateSubmitButton: UIButton!
    @IBOutlet weak var keywordTextField: UITextField!
    
    let viewModel = SettingViewModel()
    var keywordText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.getImage(keyword: keywordText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setState()
        viewModel.getFirebaseImageURL()
    }
    
    private func setLayout() {
        activityIndicatorView.isHidden = true
        
        if let imageData = UserDefaults.standard.data(forKey: imageDataKey) {
            imageView.image = UIImage(data: imageData)
        }
        keywordTextField.delegate = self
        
        let refreshGesture = UITapGestureRecognizer(target: self, action: #selector(refreshViewTapped))
        refreshPhotoView.addGestureRecognizer(refreshGesture)
        
        rateCloseButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Close", comment: "")), for: .normal)
        rateSubmitButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Submit", comment: "")), for: .normal)
    }
    
    private func setState() {
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: lightStateKey)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: darkStateKey)
        hapticSwitch.isOn = UserDefaults.standard.bool(forKey: hapticStateKey)
        lockScreenSwitch.isOn = UserDefaults.standard.bool(forKey: lockScreenKey)
    }
    
    @objc private func refreshViewTapped() {
        makeVibration(type: .rigid)
        
        viewModel.checkSystemAppReview()
        starRateView.isHidden = viewModel.checkCustomAppReview()
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            viewModel.getImage(keyword: keywordText)
            
            DispatchQueue.main.async {
                let defaultImage = UIImage(named: "meteor_splash.png")
                self.imageView.image = UIImage(data: ((self.viewModel.imageData) ?? defaultImage?.pngData())!)
                
                self.viewModel.setWidgetData()
                
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @IBAction func mailTapped(_ sender: UIButton) {
        let email = "dev.soduma@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func reviewTapped(_ sender: Any) {
        let url = "itms-apps://itunes.apple.com/app/1562989730"
        if let url = URL(string: url),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func lightModeSwitchTapped(_ sender: UISwitch) {
        darkModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if lightModeSwitch.isOn == true {
                window.overrideUserInterfaceStyle = .light
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: lightStateKey)
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: darkStateKey)
    }
    
    @IBAction func darkModeSwitchTapped(_ sender: UISwitch) {
        lightModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if darkModeSwitch.isOn == true {
                window.overrideUserInterfaceStyle = .dark
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: lightStateKey)
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: darkStateKey)
    }
    
    @IBAction func hapticSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(hapticSwitch.isOn, forKey: hapticStateKey)
    }
    
    @IBAction func lockScreenSwitchTapped(_ sender: UISwitch) {
        UserDefaults.standard.set(lockScreenSwitch.isOn, forKey: lockScreenKey)
        
        Task {
            if UserDefaults.standard.bool(forKey: liveIdlingKey) {
                await MeteorViewModel().endLiveActivity()
                
                let liveText = UserDefaults.standard.string(forKey: LiveTextKey) ?? ""
                MeteorViewModel().startLiveActivity(text: liveText)
            } else {
                UserDefaults.standard.removeObject(forKey: LiveTextKey)
            }
        }
    }
    
    @IBAction func rateSubmitTapped(_ sender: UIButton) {
        let url = "https://apps.apple.com/app/id1562989730?action=write-review"
        guard let writeReviewURL = URL(string: url) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
        UserDefaults.standard.set(viewModel.getCurrentVersion(), forKey: lastVersionKey)
        starRateView.isHidden = true
    }
    
    @IBAction func rateCloseTapped(_ sender: UIButton) {
        starRateView.isHidden = true
        viewModel.counterForCustomAppReview = 0
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            keywordText = text
        }
    }
}
