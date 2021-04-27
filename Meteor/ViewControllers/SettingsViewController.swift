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
    @IBOutlet weak var vibrateSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        lightModeSwitch.isOn = UserDefaults.standard.bool(forKey: "lightState")
        darkModeSwitch.isOn = UserDefaults.standard.bool(forKey: "darkState")
        vibrateSwitch.isOn = UserDefaults.standard.bool(forKey: "vibrateSwitch")
    }
    
    @IBAction func tapMail(_ sender: UIButton) {
        let email = "dev.soduma@gmail.com"
        
        if let url = URL(string: "mailto:\(email)") {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func tapReview(_ sender: Any) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/1562989730"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @IBAction func tapLightModeSwitch(_ sender: UISwitch) {
        darkModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {
                
                if lightModeSwitch.isOn == true {
                    window.overrideUserInterfaceStyle = .light
                    
                } else if lightModeSwitch.isOn == false {
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
        
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: "lightState")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "darkState")
        //        print("1",UserDefaults.standard.bool(forKey: "lightState"))
        //        print("2",UserDefaults.standard.bool(forKey: "darkState"))
    }
    
    @IBAction func tapDarkModeSwitch(_ sender: UISwitch) {
        lightModeSwitch.isOn = false
        
        if let window = UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {
                
                if darkModeSwitch.isOn == true {
                    window.overrideUserInterfaceStyle = .dark
                    
                } else if darkModeSwitch.isOn == false {
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
        
        UserDefaults.standard.set(lightModeSwitch.isOn, forKey: "lightState")
        UserDefaults.standard.set(darkModeSwitch.isOn, forKey: "darkState")
        //        print("3",UserDefaults.standard.bool(forKey: "lightState"))
        //        print("4",UserDefaults.standard.bool(forKey: "darkState"))
    }
    
    @IBAction func tapVibrateSwitch(_ sender: UISwitch) {
        UserDefaults.standard.set(vibrateSwitch.isOn, forKey: "vibrateSwitch")
    }
}
