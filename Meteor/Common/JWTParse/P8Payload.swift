//
//  P8Payload.swift
//  Meteor
//
//  Created by 장기화 on 4/16/24.
//

import Foundation

struct P8Payload {
    let data: Data
    
    init?(_ base64Encoded: String) {
        guard let asn1 = Data(base64Encoded: base64Encoded) else {
            return nil
        }
        data = asn1
    }
}
