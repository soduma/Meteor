//
//  InputViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/16.
//

import UIKit

class InputViewController: UIViewController {
    
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let todoViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        inputTextView.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        inputTextView.becomeFirstResponder()
    }

    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        inputTextView.resignFirstResponder()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
        guard let detail = inputTextView.text, detail.isEmpty == false else { return }
        let todo = TodoManager.shared.createTodo(detail: detail)
        todoViewModel.addTodo(todo)
        inputTextView.text = ""
        
        TodoViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromInput", sender: self)
    }
}
