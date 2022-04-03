//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import Firebase
import WidgetKit
import StoreKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var imageSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var starRateView: UIVisualEffectView!
    @IBOutlet weak var rateHeaderLabel: UILabel!
    @IBOutlet weak var rateTextLabel: UILabel!
    @IBOutlet weak var rateCloseButton: UIButton!
    @IBOutlet weak var rateSubmitButton: UIButton!
    @IBOutlet weak var keywordTextField: UITextField!
    
    let db = Database.database().reference()
    var url = "https://source.unsplash.com/random"
    var defaultURL = "https://source.unsplash.com/random"
    var imageData: Data?
    var widgetData: Data?
    var timer = Timer()
    let defaultImage = UIImage(named: "defaultImage.png")
    
    var counterForAppReview = 0
    var counterForNonAutoAppReview = 0
    var currentVersion = ""
    var keywordText = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let imageData = UserDefaults.standard.data(forKey: "imageData") {
            imageView.image = UIImage(data: imageData)
        }
        keywordTextField.delegate = self
        
        rateCloseButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Close", comment: "")), for: .normal)
        rateSubmitButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Submit", comment: "")), for: .normal)
        
        counterForAppReview = UserDefaults.standard.integer(forKey: "appReview")
        counterForNonAutoAppReview = UserDefaults.standard.integer(forKey: "nonAutoAppReview")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: "lightState")
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkState")
        vibrateSwitch.isOn = UserDefaults.standard.bool(forKey: "vibrateSwitch")
        imageSwitch.isOn = UserDefaults.standard.bool(forKey: "imageSwitch")
        
        if UserDefaults.standard.bool(forKey: "imageSwitch") {
            getImage()
        }
        appReview()
        nonAutoAppReview()
//        print(UserDefaults.standard.integer(forKey: "appReview"))
//        print(UserDefaults.standard.integer(forKey: "nonAutoAppReview"))
    }
    
    private func getImage() {
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else { return }
            
            if self.keywordText == "" {
                self.db.child("a_upsplash").observeSingleEvent(of: .value) { snapshot in
                    self.url = snapshot.value as? String ?? self.defaultURL
                }
                guard let imageURL = URL(string: self.url) else { return }
                self.imageData = try? Data(contentsOf: imageURL)
            } else {
                self.db.child("a_upsplash").observeSingleEvent(of: .value) { _ in }
                let keywordURL = "https://source.unsplash.com/featured/?\(self.keywordText)"
                guard let imageURL = URL(string: keywordURL) else { return }
                self.imageData = try? Data(contentsOf: imageURL)
            }
            
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: ((self.imageData) ?? self.defaultImage?.pngData())!)
                self.widgetData = self.imageData
                UserDefaults.standard.set(self.imageData, forKey: "imageData")
                UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(self.widgetData, forKeyPath: "widgetData")
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    private func appReview() {
        counterForAppReview += 1
//        print(counterForAppReview)
        UserDefaults.standard.set(counterForAppReview, forKey: "appReview")
        
        if counterForAppReview >= 50 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            counterForAppReview = 0
        }
    }
    
    private func nonAutoAppReview() {
        counterForNonAutoAppReview += 1
        UserDefaults.standard.set(counterForNonAutoAppReview, forKey: "nonAutoAppReview")
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            fatalError("Expected to find a bundle version in the info dictionary") }
        self.currentVersion = currentVersion
//        print("current!!! --\(currentVersion)")
        
        let lastVersion = UserDefaults.standard.string(forKey: "lastVersion")
//        print("last!!! --\(lastVersion)")
        
        if counterForNonAutoAppReview >= 20 && currentVersion != lastVersion {
            starRateView.isHidden = false
        }
    }
    
    @IBAction func tapImageSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(imageSwitch.isOn, forKey: "imageSwitch")
        
        if UserDefaults.standard.bool(forKey: "imageSwitch") {
            getImage()
        }
    }
    
    @IBAction func tapMail(_ sender: UIButton) {
        let email = "dev.soduma@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
    
    @IBAction func tapReview(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/1562989730"), UIApplication.shared.canOpenURL(url) {
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
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: "lightState")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "darkState")
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
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: "lightState")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "darkState")
    }
    
    @IBAction func tapVibrateSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(vibrateSwitch.isOn, forKey: "vibrateSwitch")
    }
    
    @IBAction func tapRateClose(_ sender: UIButton) {
        starRateView.isHidden = true
        counterForNonAutoAppReview = 0
    }
    
    @IBAction func tapRateSubmit(_ sender: UIButton) {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/app/id1562989730?action=write-review") else {
            fatalError("Expected a valid URL") }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        UserDefaults.standard.set(currentVersion, forKey: "lastVersion")
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
