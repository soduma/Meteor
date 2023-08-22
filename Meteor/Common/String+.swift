//
//  String+.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/19.
//

import Foundation

extension String {
    static func secondsToString(seconds: Int) -> String {
        if seconds >= 3600 {
            let hours = seconds / 3600
            let minutes = seconds / 60 % 60
            let seconds = seconds % 60
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            let minutes = seconds / 60 % 60
            let seconds = seconds % 60
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
