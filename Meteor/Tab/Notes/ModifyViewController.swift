//
//  ModifyViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/30.
//

import UIKit

class ModifyViewController: UIViewController {
    @IBOutlet weak var modifyTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let modifyViewModel = ModifyViewModel()
    let todoViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }

    func updateUI() {
        if let todo = modifyViewModel.todo {
            modifyTextView.text = todo.detail
        }
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        modifyTextView.resignFirstResponder()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
        guard let detail = modifyTextView.text, detail.isEmpty == false else { return }
        if var todo = modifyViewModel.todo {
            todo.detail = modifyTextView.text
            todoViewModel.updateTodo(todo)
        }
        
        TodoViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromModify", sender: self)
    }
}

class ModifyViewModel {
    var todo: Todo?
    
    func update(model: Todo?) {
        todo = model
//        print(todo)
    }
}
