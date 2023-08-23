//
//  NotesCell.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import UIKit

class NotesCell: UICollectionViewCell {
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var strikeThroughView: UIView!
    @IBOutlet weak var strikeThroughWidth: NSLayoutConstraint!
    
    static let idendifier = "NotesCell"
    var doneButtonTapHandler: ((Bool) -> Void)?
    var deleteButtonTapHandler: (() -> Void)?
    
    // 셀 클릭시 하이라이트
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                UIView.animate(withDuration: 0.5) {
                    self.backgroundColor = UIColor.systemGray4
                    self.backgroundColor = UIColor.clear
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        resetUI()
    }
    
    func setLayout(_ todo: Todo) {
        checkButton.isSelected = todo.isDone
        descriptionLabel.text = todo.detail
        deleteButton.isHidden = todo.isDone == false
        
        if checkButton.isSelected == true {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
        } else {
            showStrikeThrough(todo.isDone)
        }
    }
    
    private func showStrikeThrough(_ isShow: Bool) {
        if isShow {
            strikeThroughWidth.constant = descriptionLabel.bounds.width
            UIView.animate(withDuration: 0.2) { self.contentView.layoutIfNeeded() }
        } else {
            strikeThroughWidth.constant = 0
        }
    }
    
    private func resetUI() {
        deleteButton.isHidden = true
        showStrikeThrough(false)
    }
    
    @IBAction func tapCheckButton(_ sender: UIButton) {
        makeVibration(type: .rigid)
        checkButton.isSelected = !checkButton.isSelected
        
        let isDone = checkButton.isSelected
        deleteButton.isHidden = !isDone
        showStrikeThrough(isDone)
        doneButtonTapHandler?(isDone)
    }
    
    @IBAction func tapDeleteButton(_ sender: UIButton) {
        deleteButtonTapHandler?()
    }
}
