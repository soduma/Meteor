//
//  ToastManager.swift
//  Meteor
//
//  Created by 장기화 on 9/15/23.
//

import UIKit
import Toast

class ToastManager {
    static var toast = Toast.text("")
    
    static func makeToast(toast: inout Toast, title: String, subTitle: String? = nil, imageName: String) {
        toast.close()
        guard let image = UIImage(systemName: imageName) else { return }
        let title = NSLocalizedString(title, comment: "")
        
        if let subTitle {
            let toastConfig = ToastConfiguration(
                autoHide: true,
                enablePanToClose: true,
                displayTime: 3)
            let subTitle = NSLocalizedString(subTitle, comment: "")
            toast = Toast.default(image: image, title: title, subtitle: subTitle, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
        } else {
            let toastConfig = ToastConfiguration(
                direction: .bottom,
                autoHide: true,
                enablePanToClose: true,
                displayTime: 3)
            toast = Toast.default(image: image, title: title, config: toastConfig)
            toast.enableTapToClose()
            toast.show()
        }
    }
}
