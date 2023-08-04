//
//  TodoViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/04.
//

import Foundation

class TodoViewModel {
    private let manager = TodoManager.shared
    
    var todos: [Todo] {
        return manager.todos
    }
    
    func addTodo(_ todo: Todo) {
        manager.addTodo(todo)
    }
    
    func deleteTodo(_ todo: Todo) {
        manager.deleteTodo(todo)
    }
    
    func updateTodo(_ todo: Todo) {
        manager.updateTodo(todo)
    }
    
    func loadTasks() {
        manager.retrieveTodo()
    }
}
