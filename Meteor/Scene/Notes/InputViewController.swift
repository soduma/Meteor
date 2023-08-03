//
//  InputViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/16.
//

import UIKit
import Firebase

class InputViewController: UIViewController {
    @IBOutlet weak var inputTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let todoViewModel = TodoViewModel()
    var db = Database.database().reference()
    
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
        let text = inputTextView.text
        inputTextView.text = ""
        
        //firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        db.child("longText").child(user).childByAutoId().setValue(["text": text, "time": dateTime, "locale": locale])
        
        TodoViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromInput", sender: self)
    }
}
