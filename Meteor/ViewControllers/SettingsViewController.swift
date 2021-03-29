//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var lightModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lightModeSwitch.isOn = false
    }
    
    @IBAction func tapInfofield(_ sender: UIButton) {
        let Username =  "infofield" // Your Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared

        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: "https://instagram.com/\(Username)")!
            application.open(webURL)
        }
    }
    
    @IBAction func tapNamkevmin(_ sender: UIButton) {
        let Username =  "namkevmin" // Your Instagram Username here
        let appURL = URL(string: "instagram://user?username=\(Username)")!
        let application = UIApplication.shared

        if application.canOpenURL(appURL) {
            application.open(appURL)
        } else {
            // if Instagram app is not installed, open URL inside Safari
            let webURL = URL(string: "https://instagram.com/\(Username)")!
            application.open(webURL)
        }
    }
    
    @IBAction func tapLightModeSwitch(_ sender: UISwitch) {
        if let window = UIApplication.shared.windows.first {
            if #available(iOS 13.0, *) {

                if lightModeSwitch.isOn == true {
                    window.overrideUserInterfaceStyle = .light
                    
                } else if lightModeSwitch.isOn == false {
                    window.overrideUserInterfaceStyle = .unspecified
                }
            }
        }
    }
}
