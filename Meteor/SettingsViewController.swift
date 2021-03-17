//
//  TableViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        darkModeSwitch.isOn = false
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
    

    
//    @IBAction func tapDarkModeSwitch(_ sender: UISwitch) {
//        if darkModeSwitch.isOn == true {
//            self.overrideUserInterfaceStyle = .light
//        }
//    }
}
//let darkModeSwitchIsOn = defaults.bool(forKey: darkModeSwitchAct)
//        darkModeSwitchOutlet.isOn = darkModeSwitchIsOn
//        if darkModeSwitchIsOn {
//            self.view.backgroundColor = .black
//        } else {
//            self.view.backgroundColor = .white
//        }
