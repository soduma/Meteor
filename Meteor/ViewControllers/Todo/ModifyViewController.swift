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
    @IBOutlet weak var closeButton: UIButton!
    
//    let modifyViewModel = ModifyViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        updateUI()
    }
    
//    func updateUI() {
//        if let todo = modifyViewModel.todo {
//            modifyTextView.text = todo.detail
//        }
//    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        modifyTextView.resignFirstResponder()
    }
    
    //    @IBAction func tapFinishButton(_ sender: UIButton) {
    //        guard let detail = modifyTextView.text, detail.isEmpty == false else { return }
    //        let todo = TodoManager.shared.updateTodo(Todo)
    //        todoViewModel.updateTodo(todo)
    //        TodoViewController().collectionView?.reloadData()
    //        self.performSegue(withIdentifier: "fromModify", sender: self)
    //        dismiss(animated: true, completion: nil)
    //}
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//class ModifyViewModel {
//    var todo: Todo?
//
//    func update(model: Todo?) {
//        todo = model
//    }
//}
