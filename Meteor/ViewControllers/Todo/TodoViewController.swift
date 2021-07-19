//
//  TodoViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit
import Firebase

class TodoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
//    @IBOutlet weak var collectionViewBottom: NSLayoutConstraint!
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
    
    let todoViewModel = TodoViewModel()
    var db = Database.database().reference()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showModify" {
            let vc = segue.destination as? ModifyViewController
            if let index = sender as? Int {
                let todo = todoViewModel.todos[index]
                vc?.modifyViewModel.update(model: todo)
                //                print(todoViewModel.todos[index])
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        todoViewModel.loadTasks()
        bottomView.layer.cornerRadius = 27
        longBlurView.layer.cornerRadius = 21
        shortBlurView.layer.cornerRadius = 21
        textFieldBlurView.layer.cornerRadius = 21
        
        tapGestureRecognizer.isEnabled = false
//        shortTextField.isHidden = true
//        sendButton.isHidden = true
        xButton.isHidden = true
        textFieldBlurView.isHidden = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustInputView), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        getBottomViewImage()
    }
    
    func getBottomViewImage() {
        if UserDefaults.standard.bool(forKey: "imageSwitch") == false {
//            self.imageView.image = nil
            
        } else {
            DispatchQueue.global(qos: .userInteractive).async {
                let url = "https://picsum.photos/400/100"
                guard let imageURL = URL(string: url) else { return }
                guard let data = try? Data(contentsOf: imageURL) else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
        }
    }
    
    @objc private func adjustInputView(noti: Notification) {
        guard let userInfo = noti.userInfo else { return }
        guard let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut) {
                if noti.name == UIResponder.keyboardWillShowNotification {
                    let adjustmentHeight = keyboardFrame.height - self.view.safeAreaInsets.bottom
                    self.bottomViewBottom.constant = adjustmentHeight + 5
//                    self.collectionViewBottom.constant = adjustmentHeight
                } else {
                    self.bottomViewBottom.constant = 5
//                    self.collectionViewBottom.constant = 0
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
//            shortTextField.isHidden = true
//            sendButton.isHidden = true
            textFieldBlurView.isHidden = true
            shortTextField.resignFirstResponder()
            tapGestureRecognizer.isEnabled = false
        }
    }
    
    @IBAction func tapTextField(_ sender: UITextField) {
        tapGestureRecognizer.isEnabled = true
    }
    
    @IBAction func tapLongButton(_ sender: UIButton) {
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    @IBAction func tapShortButton(_ sender: UIButton) {
        longBlurView.isHidden = true
        shortBlurView.isHidden = true
        xButton.isHidden = false
//        shortTextField.isHidden = false
//        sendButton.isHidden = false
        textFieldBlurView.isHidden = false
        shortTextField.becomeFirstResponder()
        tapGestureRecognizer.isEnabled = true
        
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    @IBAction func tapXButton(_ sender: UIButton) {
        longBlurView.isHidden = false
        shortBlurView.isHidden = false
        xButton.isHidden = true
//        shortTextField.isHidden = true
//        sendButton.isHidden = true
        textFieldBlurView.isHidden = true
        shortTextField.text = ""
        shortTextField.resignFirstResponder()
    }
    
    @IBAction func tapSendButton(_ sender: UIButton) {
        guard let detail = shortTextField.text, detail.isEmpty == false else { return }
        let todo = TodoManager.shared.createTodo(detail: detail)
        todoViewModel.addTodo(todo)
        let text = shortTextField.text
        shortTextField.text = ""
        collectionView.reloadData()
        
        let item = self.collectionView(self.collectionView, numberOfItemsInSection: 0) - 1
        let lastItemIndex = IndexPath(item: item, section: 0)
        self.collectionView.scrollToItem(at: lastItemIndex, at: .top, animated: true)
        
        //firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        db.child("shortText").child(user).childByAutoId().setValue(["text": text, "time": dateTime, "locale": locale])
        
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            let generator = UIImpactFeedbackGenerator(style: .rigid)
            generator.impactOccurred()
        }
    }
}

extension TodoViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return todoViewModel.todos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TodoCell", for: indexPath) as? TodoCell else {
            return UICollectionViewCell()
        }
        
        var todo: Todo
        todo = todoViewModel.todos[indexPath.item]
        //        print("cellfortiem \(todo)")
        cell.updateUI(todo)
        
        cell.doneButtonTapHandler = { isDone in
            todo.isDone = isDone
            self.todoViewModel.updateTodo(todo)
            //            self.collectionView.reloadData()
        }
        
        cell.deleteButtonTapHandler = {
            self.todoViewModel.deleteTodo(todo)
            self.collectionView.reloadData()
        }
        
        return cell
    }
}

extension TodoViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            performSegue(withIdentifier: "showModify", sender: indexPath.item)
    }
}

extension TodoViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width: CGFloat = collectionView.bounds.width
        let height: CGFloat = 50
        return CGSize(width: width, height: height)
    }
}

class TodoCell: UICollectionViewCell {
    
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView!
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        reset()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func updateUI(_ todo: Todo) {
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        deleteButton.isHidden = todo.isDone == false
        
        if checkButton.isSelected == true {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            showStrikeThrough(todo.isDone)
        }
    }
    
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
            UIView.animate(withDuration: 0.2) {
                self.contentView.layoutIfNeeded()
            }
        } else {
            strikeThroughWidth.constant = 0
        }
    }
    
    func reset() {
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }
    
    @IBAction func tapCheckButton(_ sender: UIButton) {
        checkButton.isSelected = !checkButton.isSelected
        let isDone = checkButton.isSelected
        deleteButton.isHidden = !isDone
        showStrikeThrough(isDone)
        doneButtonTapHandler?(isDone)
        
        if UserDefaults.standard.bool(forKey: "vibrateSwitch") == true {
            if #available(iOS 13.0, *) {
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            } else {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
            }
        }
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        deleteButtonTapHandler?()
    }
    
    // 셀 클릭시 하이라이트
    override var isSelected: Bool {
        didSet{
            if self.isSelected {
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = UIColor.systemGray4
                    self.backgroundColor = UIColor.clear
                }
            }
        }
    }
}
