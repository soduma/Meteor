//
//  NotesViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class NotesViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var bottomViewBottom: NSLayoutConstraint!
    @IBOutlet weak var longBlurView: UIVisualEffectView!
    @IBOutlet weak var shortBlurView: UIVisualEffectView!
    @IBOutlet weak var textFieldBlurView: UIVisualEffectView!
    
    @IBOutlet weak var longButton: UIButton!
    @IBOutlet weak var shortButton: UIButton!
    @IBOutlet weak var shortTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var xButton: UIButton!
    
    let viewModel = NotesViewModel()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showModify" {
            if let index = sender as? Int {
                let todo = viewModel.todos[index]
                NotesViewModel.todo = todo
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setLayout()
        viewModel.loadTasks()
//        getBottomViewImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(
            self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func setLayout() {
        bottomView.layer.cornerRadius = 27
        longBlurView.layer.cornerRadius = 21
        shortBlurView.layer.cornerRadius = 21
        textFieldBlurView.layer.cornerRadius = 21
        
        tapGestureRecognizer.isEnabled = false
        xButton.isHidden = true
        textFieldBlurView.isHidden = true
    }
    
//    private func getBottomViewImage() {
//        let url = "https://picsum.photos/400/100"
//        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//            guard let self = self else { return }
//            guard let imageURL = URL(string: url),
//                  let data = try? Data(contentsOf: imageURL) else { return }
//
//            DispatchQueue.main.async {
//                self.imageView.image = UIImage(data: data)
//            }
//        }
//    }
    
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: .curveEaseInOut) {
                if noti.name == UIResponder.keyboardWillShowNotification {
                    let adjustmentHeight = keyboardFrame.height - self.view.safeAreaInsets.bottom
                    self.bottomViewBottom.constant = adjustmentHeight + 5
                } else {
                    self.bottomViewBottom.constant = 5
                }
                self.view.layoutIfNeeded()
            }
        }
        print("---> Keyboard End Frame: \(keyboardFrame)")
    }
    
    @IBAction func unwindToTodoViewController(segue: UIStoryboardSegue) {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    @IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
        if shortTextField.becomeFirstResponder() {
            shortTextField.resignFirstResponder()
            tapGestureRecognizer.isEnabled = false
        }
        
        if shortTextField.text?.isEmpty == true {
            longBlurView.isHidden = false
            shortBlurView.isHidden = false
            xButton.isHidden = true
            textFieldBlurView.isHidden = true
            tapGestureRecognizer.isEnabled = false
            shortTextField.resignFirstResponder()
        }
    }
    
    @IBAction func tapTextField(_ sender: UITextField) {
        tapGestureRecognizer.isEnabled = true
    }
    
    @IBAction func tapLongButton(_ sender: UIButton) {
        makeVibration(type: .medium)
    }
    
    @IBAction func tapShortButton(_ sender: UIButton) {
        makeVibration(type: .medium)
        
        longBlurView.isHidden = true
        shortBlurView.isHidden = true
        xButton.isHidden = false
        textFieldBlurView.isHidden = false
        tapGestureRecognizer.isEnabled = true
        shortTextField.becomeFirstResponder()
    }
    
    @IBAction func tapXButton(_ sender: UIButton) {
        longBlurView.isHidden = false
        shortBlurView.isHidden = false
        xButton.isHidden = true
        textFieldBlurView.isHidden = true
        shortTextField.text = ""
        shortTextField.resignFirstResponder()
    }
    
    @IBAction func tapArrowButton(_ sender: UIButton) {
        guard let text = shortTextField.text,
              text.isEmpty == false else { return }
        makeVibration(type: .success)
        viewModel.saveShort(text: text)
        
        shortTextField.text = ""
        collectionView.reloadData()
        
        let item = collectionView(collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
    }
}

extension NotesViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.todos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NotesCell.idendifier, for: indexPath) as? NotesCell else {
            return UICollectionViewCell()
        }
        
        var todo = viewModel.todos[indexPath.item]
        cell.setLayout(todo)
        
        cell.doneButtonTapHandler = { isDone in
            todo.isDone = isDone
            self.viewModel.updateTodo(todo)
        }
        
        cell.deleteButtonTapHandler = {
            self.viewModel.deleteTodo(todo)
            self.collectionView.reloadData()
        }
        return cell
    }
}

extension NotesViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showModify", sender: indexPath.item)
    }
}

extension NotesViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
    }
}
