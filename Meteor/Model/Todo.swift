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

class TodoManager {
    static let shared = TodoManager()
    static var lastId: Int = 0
    
    var todos:[Todo] = []
    
    func createTodo(detail: String) -> Todo {
        let nextId = TodoManager.lastId + 1
        TodoManager.lastId = nextId
        
        return Todo(id: nextId, isDone: false, detail: detail)
    }
    
    func addTodo(_ todo: Todo) {
        todos.append(todo)
//        todos.insert(todo, at: 0)
        saveTodo()
    }
    
    func deleteTodo(_ todo: Todo) {
        if let index = todos.firstIndex(of: todo) {
            todos.remove(at: index)
        }
//        todos = todos.filter { $0.id != todo.id }
        saveTodo()
    }
    
    func updateTodo(_ todo: Todo) {
        guard let index = todos.firstIndex(of: todo) else { return }
        todos[index].update(isDone: todo.isDone, detail: todo.detail)
        saveTodo()
    }
    
    func saveTodo() {
        Storage.store(todos, to: .documents, as: "todos.json")
    }
    
    func retrieveTodo() {
        todos = Storage.retrive("todos.json", from: .documents, as: [Todo].self) ?? []
        
        let lastId = todos.last?.id ?? 0
        TodoManager.lastId = lastId
    }
}

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
