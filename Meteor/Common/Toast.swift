//
//  Toast.swift
//  Meteor
//
//  Created by 장기화 on 9/15/23.
//

import UIKit
import Toast

func makeToast(toast: inout Toast, title: String, subTitle: String, imageName: String) {
    toast.close()
    
    if subTitle.isEmpty {
        let title = NSLocalizedString(title, comment: "")
        toast = Toast.text(title)
        toast.enableTapToClose()
        toast.show()
    } else {
        let title = NSLocalizedString(title, comment: "")
        let subTitle = NSLocalizedString(subTitle, comment: "")
        let toastConfig = ToastConfiguration(autoHide: true, enablePanToClose: true, displayTime: 3)
        toast = Toast.default(image: UIImage(systemName: imageName)!, title: title, subtitle: subTitle, config: toastConfig)
        toast.enableTapToClose()
        toast.show()
    }
}
