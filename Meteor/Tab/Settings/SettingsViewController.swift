//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import WidgetKit
import StoreKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var refreshPhotoView: UIView!
    
    @IBOutlet weak var starRateView: UIVisualEffectView!
    @IBOutlet weak var rateHeaderLabel: UILabel!
    @IBOutlet weak var rateTextLabel: UILabel!
    @IBOutlet weak var rateCloseButton: UIButton!
    @IBOutlet weak var rateSubmitButton: UIButton!
    @IBOutlet weak var keywordTextField: UITextField!
    
    let viewModel = SettingViewModel()
    
    var counterForSystemAppReview = 0
    var counterForCustomAppReview = 0
    var currentVersion = ""
    var keywordText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.getImage(keyword: keywordText)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setState()
    }
    
    private func setLayout() {
        if let imageData = UserDefaults.standard.data(forKey: ImageDataKey) {
            imageView.image = UIImage(data: imageData)
        }
        keywordTextField.delegate = self
        
        let refreshGesture = UITapGestureRecognizer(target: self, action: #selector(tapRefreshView))
        refreshPhotoView.addGestureRecognizer(refreshGesture)
        
        rateCloseButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Close", comment: "")), for: .normal)
        rateSubmitButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Submit", comment: "")), for: .normal)
        
        counterForSystemAppReview = UserDefaults.standard.integer(forKey: SystemAppReviewCount)
        counterForCustomAppReview = UserDefaults.standard.integer(forKey: CustomAppReviewCount)
    }
    
    private func setState() {
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: LightState)
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: DarkState)
        vibrateSwitch.isOn = UserDefaults.standard.bool(forKey: VibrateState)
    }
    
    private func checkSystemAppReview() {
        counterForSystemAppReview += 1
        UserDefaults.standard.set(counterForSystemAppReview, forKey: SystemAppReviewCount)
        
        if counterForSystemAppReview >= 30 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            counterForSystemAppReview = 0
        }
    }
    
    private func checkCustomAppReview() {
        counterForCustomAppReview += 1
        UserDefaults.standard.set(counterForCustomAppReview, forKey: CustomAppReviewCount)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            return print("Expected to find a bundle version in the info dictionary") }
        
        self.currentVersion = currentVersion
        let lastVersion = UserDefaults.standard.string(forKey: LastVersion)
        
        if counterForCustomAppReview >= 20 && currentVersion != lastVersion {
            starRateView.isHidden = false
        }
    }
    
    @objc private func tapRefreshView() {
        makeVibration(type: .rigid)
        
        checkSystemAppReview()
        checkCustomAppReview()
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            viewModel.getImage(keyword: keywordText)
            
            DispatchQueue.main.async {
                let defaultImage = UIImage(named: "meteor_logo.png")
                self.imageView.image = UIImage(data: ((self.viewModel.imageData) ?? defaultImage?.pngData())!)
                
                self.viewModel.setWidgetData()
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    @IBAction func tapMail(_ sender: UIButton) {
        let email = "dev.soduma@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapReview(_ sender: Any) {
        let url = "itms-apps://itunes.apple.com/app/1562989730"
        if let url = URL(string: url),
           UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapLightModeSwitch(_ sender: UISwitch) {
        darkModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if lightModeSwitch.isOn == true {
                window.overrideUserInterfaceStyle = .light
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: LightState)
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: DarkState)
    }
    
    @IBAction func tapDarkModeSwitch(_ sender: UISwitch) {
        lightModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if darkModeSwitch.isOn == true {
                window.overrideUserInterfaceStyle = .dark
            } else {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: LightState)
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: DarkState)
    }
    
    @IBAction func tapVibrateSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(vibrateSwitch.isOn, forKey: VibrateState)
    }
    
    @IBAction func tapRateClose(_ sender: UIButton) {
        starRateView.isHidden = true
        counterForCustomAppReview = 0
    }
    
    @IBAction func tapRateSubmit(_ sender: UIButton) {
        let url = "https://apps.apple.com/app/id1562989730?action=write-review"
        guard let writeReviewURL = URL(string: url) else { return }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
        UserDefaults.standard.set(currentVersion, forKey: LastVersion)
        starRateView.isHidden = true
    }
}

extension SettingsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        keywordTextField.resignFirstResponder()
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let text = textField.text {
            self.keywordText = text
        }
    }
}
