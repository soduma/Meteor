//
//  ModifyViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/04.
//

import Foundation

class ModifyViewModel {
    var todo: Todo?
    
    func update(model: Todo?) {
        todo = model
//        print(todo)
    }
}
