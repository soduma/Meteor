//
//  NoticeCollectionViewCell.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import UIKit

class NoticeCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var noticeLabel: UILabel!
    
    static let identifier = "NoticeCell"
    
    func setLayout(notice: String) {
        noticeLabel.text = notice
    }
}
