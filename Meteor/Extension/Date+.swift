//
//  Date+.swift
//  Meteor
//
//  Created by 장기화 on 4/17/24.
//

import Foundation

extension Date {
    static var timestamp: Int {
        return Int(Date().timeIntervalSince1970.rounded())
    }
}
