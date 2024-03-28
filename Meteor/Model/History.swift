//
//  History.swift
//  Meteor
//
//  Created by 장기화 on 3/28/24.
//

import Foundation
import SwiftData

@Model
class History {
    @Attribute(.unique) var id = UUID()
    var content: String
    var timestamp: TimeInterval
    
    init(content: String, timestamp: TimeInterval) {
        self.content = content
        self.timestamp = timestamp
    }
}
