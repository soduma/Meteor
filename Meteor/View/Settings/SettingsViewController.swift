//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class SettingsViewController: UITableViewController {
    let viewModel = SettingsViewModel()
    
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
        makeVibration(type: .rigid)
        
        viewModel.systemAppReview()
        starRateView.isHidden = !viewModel.customAppReview()
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            viewModel.getNewImage(keyword: viewModel.keywordText)
            
            DispatchQueue.main.async {
                let defaultImage = UIImage(named: "meteor_splash.png")
                self.imageView.image = UIImage(data: ((self.viewModel.imageData) ?? defaultImage?.pngData())!)
                self.activityIndicatorView.isHidden = true
                self.activityIndicatorView.stopAnimating()
            }
        }
    }
    
    @IBAction func mailButtonTapped(_ sender: UIButton) {
        let email = "dev.soduma@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
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
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveIdlingKey) {
            Task {
                await MeteorViewModel().endLiveActivity()
                
                let liveText = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? ""
                MeteorViewModel().startLiveActivity(text: liveText)
            }
        } else {
            UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.liveTextKey)
        }
    }
    
    @IBAction func liveColorSegmentedControlTapped(_ sender: UISegmentedControl) {
        makeVibration(type: .rigid)
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveIdlingKey) {
            _ = viewModel.customAppReview()
        }
        
        switch sender.selectedSegmentIndex {
        case 0:
            viewModel.liveColor = .red
        case 1:
            viewModel.liveColor = .black
        default:
            viewModel.liveColor = .clear
        }
        UserDefaults.standard.set(viewModel.liveColor.rawValue, forKey: UserDefaultsKeys.liveColorKey)
        
        if UserDefaults.standard.bool(forKey: UserDefaultsKeys.liveIdlingKey) {
            Task {
                await MeteorViewModel().endLiveActivity()
                
                let liveText = UserDefaults.standard.string(forKey: UserDefaultsKeys.liveTextKey) ?? ""
                MeteorViewModel().startLiveActivity(text: liveText)
            }
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
            viewModel.keywordText = ""
            
        } else if textField.text != "",
                  let text = textField.text {
            let removeBlanks = text.replacingOccurrences(of: " ", with: "")
            textField.text = removeBlanks
            viewModel.keywordText = removeBlanks
        }
    }
}
