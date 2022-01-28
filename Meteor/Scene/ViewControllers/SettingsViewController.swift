//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import Firebase
import SwiftUI
import WidgetKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var versionButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var vibrateSwitch: UISwitch!
    @IBOutlet weak var imageSwitch: UISwitch!
    @IBOutlet weak var imageView: UIImageView!
    
    let db = Database.database().reference()
    var url = "https://source.unsplash.com/random"
    var imageData: Data!
    var widgetData: Data!
    var timer = Timer()
    let defaultImage = UIImage(named: "defaultImage.png")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: "lightState")
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkState")
        vibrateSwitch.isOn = UserDefaults.standard.bool(forKey: "vibrateSwitch")
        imageSwitch.isOn = UserDefaults.standard.bool(forKey: "imageSwitch")
        
        getImage()
    }
    
    @objc func getImage() {
        if UserDefaults.standard.bool(forKey: "imageSwitch") {
            DispatchQueue.global(qos: .userInteractive).async {
                self.db.child("a_upsplash").observeSingleEvent(of: .value) { snapshot in
                    self.url = snapshot.value as? String ?? "https://source.unsplash.com/random"
                }
                guard let imageURL = URL(string: self.url) else { return }
                self.imageData = try? Data(contentsOf: imageURL)
                
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: ((self.imageData) ?? self.defaultImage?.pngData())!)
                    self.widgetData = self.imageData
                    UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(self.widgetData, forKeyPath: "imageData")
                    WidgetCenter.shared.reloadAllTimelines()
                }
            }
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
            } else if lightModeSwitch.isOn == false {
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
            } else if darkModeSwitch.isOn == false {
                window.overrideUserInterfaceStyle = .unspecified
            }
        }
        
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: "lightState")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "darkState")
    }
    
    @IBAction func tapVibrateSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(vibrateSwitch.isOn, forKey: "vibrateSwitch")
    }
}