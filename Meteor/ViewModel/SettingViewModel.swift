//
//  SettingViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import Foundation
import Firebase
import StoreKit
import WidgetKit

class SettingViewModel {
    let db = Database.database().reference()
    var url = ""
    var defaultURL = "https://source.unsplash.com/random"
    
    var imageData: Data?
    var widgetData: Data?
    var counterForSystemAppReview = UserDefaults.standard.integer(forKey: SystemAppReview)
    var counterForCustomAppReview = UserDefaults.standard.integer(forKey: CustomAppReview)
    var getImageCount = UserDefaults.standard.integer(forKey: UserGetImageCount)
    
    func getImageURL() {
        db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            url = snapshot.value as? String ?? defaultURL
        }
    }
    
    func getImage(keyword: String) {
        getImageCount += 1
        UserDefaults.standard.set(getImageCount, forKey: UserGetImageCount)
        
        if keyword.isEmpty {
            guard let imageURL = URL(string: url) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
            
        } else {
            let keywordURL = "https://source.unsplash.com/featured/?\(keyword)"
            guard let imageURL = URL(string: keywordURL) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
        }
        
        // for Firebase
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let dateTime = dateFormatter.string(from: Date())
        let locale = TimeZone.current.identifier
        
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.db
            .child("getImage")
            .child(user)
            .setValue(["locale": locale, "count": getImageCount])
    }
    
    func setWidgetData() {
        widgetData = imageData
        UserDefaults.standard.set(imageData, forKey: ImageDataKey)
        UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(self.widgetData, forKeyPath: "widgetDataKey")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func checkSystemAppReview() {
        counterForSystemAppReview += 1
        UserDefaults.standard.set(counterForSystemAppReview, forKey: SystemAppReview)
        
        if counterForSystemAppReview >= 35 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            counterForSystemAppReview = 0
        }
    }
    
    func checkCustomAppReview() -> Bool {
        counterForCustomAppReview += 1
        UserDefaults.standard.set(counterForCustomAppReview, forKey: CustomAppReview)
        print(counterForCustomAppReview)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return true
        }
        
        let lastVersion = UserDefaults.standard.string(forKey: LastVersion)
        
        if counterForCustomAppReview >= 20 && currentVersion != lastVersion {
            return false
        } else {
            return true
        }
    }
    
    func getCurrentVersion() -> String {
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return ""
        }
        return currentVersion
    }
}
