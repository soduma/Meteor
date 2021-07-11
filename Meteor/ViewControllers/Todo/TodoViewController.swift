//
//  TodoViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class TodoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var bottomView: UIView!
    
    let todoViewModel = TodoViewModel()
    
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
        bottomView.layer.cornerRadius = 25
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.global(qos: .userInitiated).async {
            let url = "https://picsum.photos/400/100"
            guard let imageURL = URL(string: url) else { return }
            guard let data = try? Data(contentsOf: imageURL) else { return }
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: data)
            }
        }
        
    }
    
    @IBAction func unwindToTodoViewController(segue: UIStoryboardSegue) {
        DispatchQueue.global(qos: .userInitiated).async {
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
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
