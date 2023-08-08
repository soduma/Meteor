//
//  TodoViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/04.
//

import Foundation
import UIKit.UIDevice
import Firebase

class TodoViewModel {
    private let manager = TodoManager.shared
    var db = Database.database().reference()
    
    static var todo: Todo?
    
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
    
    func saveShort(text: String) {
        let todo = manager.createTodo(detail: text)
        addTodo(todo)
        
        // for Firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        db.child(shortText).child(user).childByAutoId().setValue(["text": text, "time": dateTime, "locale": locale])
    }
    
    func saveLong(text: String) {
        let todo = manager.createTodo(detail: text)
        addTodo(todo)
        
        // for Firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        db.child(longText).child(user).childByAutoId().setValue(["text": text, "time": dateTime, "locale": locale])
    }
}
