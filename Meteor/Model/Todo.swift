//
//  Todo.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/17.
//

import UIKit

struct Todo: Codable, Equatable {
    let id: Int
    var isDone: Bool
    var detail: String
    
    mutating func update(isDone: Bool, detail: String) {
        self.isDone = isDone
        self.detail = detail
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
}
