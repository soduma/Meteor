//
//  String+.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/19.
//

import Foundation

extension String {
    static func secondsToString(seconds: Int) -> String {
        let totalSeconds = Int(seconds)
        let min = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", min, seconds)
    }
}
