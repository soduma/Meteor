//
//  VersionViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/04/14.
//

import UIKit

class VersionViewController: UIViewController {
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var idButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        makeVibration(type: .medium)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = "Current Version \(version)"
        }
    }
    
    @IBAction func tapIdButton(_ sender: UIButton) {
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
