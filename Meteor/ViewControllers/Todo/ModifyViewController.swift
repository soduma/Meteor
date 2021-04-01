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
    
    let modifyViewModel = ModifyViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateUI()
    }
    
    func updateUI() {
        if let todo = modifyViewModel.todo {
            modifyTextView.text = todo.detail
            print(todo)
        }
    }
    
    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        modifyTextView.resignFirstResponder()
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

class ModifyViewModel {
    var todo: Todo?
    
    func update(model: Todo?) {
        todo = model
        print(todo)
    }
}
