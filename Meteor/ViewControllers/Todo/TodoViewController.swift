//
//  TodoViewController.swift
//  Meteor
//
//  Created by 장기화 on 2021/03/14.
//

import UIKit

class TodoViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tapAddButton: UIButton!
    
    let todoViewModel = TodoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        todoViewModel.loadTasks()
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
        cell.updateUI(todo)
        
        cell.doneButtonTapHandler = { isDone in
            todo.isDone = isDone
            self.todoViewModel.updateTodo(todo)
            self.collectionView.reloadData()
        }
        
        cell.deleteButtonTapHandler = {
            self.todoViewModel.deleteTodo(todo)
            self.collectionView.reloadData()
        }
        
        return cell
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
        showStrikeThrough(todo.isDone)
    }
    
    private func showStrikeThrough(_ show: Bool) {
        if show {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
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
        showStrikeThrough(isDone)
        deleteButton.isHidden = !isDone
        
        doneButtonTapHandler?(isDone)
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        deleteButtonTapHandler?()
    }
    
    
}
