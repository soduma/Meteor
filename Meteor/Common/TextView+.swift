//
//  TextView+.swift
//  Meteor
//
//  Created by 장기화 on 2023/09/10.
//

import UIKit

extension UITextView {
    // MARK: textView 중간에 오도록
    open override var contentSize: CGSize {
        didSet {
            var topCorrection = (bounds.size.height - contentSize.height * zoomScale) / 2.0
            topCorrection = max(0, topCorrection)
            contentInset = UIEdgeInsets(top: topCorrection, left: 0, bottom: 0, right: 0)
        }
    }
}
