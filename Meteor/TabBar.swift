//
//  TabBar.swift
//  Meteor
//
//  Created by 장기화 on 2021/05/07.
//

import UIKit

class CustomTabBar: UITabBar {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.masksToBounds = true
        layer.cornerRadius = 25
        layer.borderColor = UIColor.systemGray.cgColor
        layer.borderWidth = 0.5
        layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
    }
}
