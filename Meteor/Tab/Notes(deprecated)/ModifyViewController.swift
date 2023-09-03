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
    
    let viewModel = NotesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setData()
    }

    private func setData() {
        if let todo = NotesViewModel.todo {
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
        guard let detail = modifyTextView.text,
              detail.isEmpty == false else { return }
        if var todo = NotesViewModel.todo {
            todo.detail = modifyTextView.text
            viewModel.updateTodo(todo)
        }
        
        NotesViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromModify", sender: self)
    }
}