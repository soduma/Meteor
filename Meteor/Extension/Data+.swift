//
//  Data+.swift
//  Meteor
//
//  Created by 장기화 on 4/15/24.
//

import Foundation

extension Data {
    /// DeviceToken Data -> String
    var hexadecimalString: String {
        self.reduce("") {
            $0 + String(format: "%02x", $1)
        }
    }
    
    func base64EncodedURLString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}
