//
//  VersionViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/04/14.
//

import UIKit

class VersionViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var infofieldButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Current Version \(version)"
        }
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
}
