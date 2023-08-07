//
//  SettingViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import Foundation
import Firebase

class SettingViewModel {
    let db = Database.database().reference()
    var url = ""
    var defaultURL = "https://source.unsplash.com/random"
    
    var imageData: Data?
    var widgetData: Data?
    
    func getImage(keyword: String) {
        if keyword.isEmpty {
            db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
                guard let self = self else { return }
                self.url = snapshot.value as? String ?? self.defaultURL
            }
            guard let imageURL = URL(string: self.url) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
            
        } else {
            let keywordURL = "https://source.unsplash.com/featured/?\(keyword)"
            guard let imageURL = URL(string: keywordURL) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
        }
    }
    
    func setWidgetData() {
        widgetData = imageData
        UserDefaults.standard.set(imageData, forKey: ImageDataKey)
        UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(self.widgetData, forKeyPath: "widgetDataKey")
    }
}
