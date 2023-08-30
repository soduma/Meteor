//
//  CreateViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/16.
//

import UIKit

class CreateViewController: UIViewController {
    @IBOutlet weak var createTextView: UITextView!
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    
    let viewModel = NotesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createTextView.text = ""
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        createTextView.becomeFirstResponder()
    }

    @IBAction func tapBG(_ sender: UITapGestureRecognizer) {
        createTextView.resignFirstResponder()
    }
    
    @IBAction func tapBackButton(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapFinishButton(_ sender: UIButton) {
        guard let text = createTextView.text,
              text.isEmpty == false else { return }
        viewModel.saveLong(text: text)
        
        NotesViewController().collectionView?.reloadData()
        self.performSegue(withIdentifier: "fromInput", sender: self)
    }
}
