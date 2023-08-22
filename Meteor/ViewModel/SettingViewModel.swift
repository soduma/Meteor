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
    private let db = Database.database().reference()
    private var firebaseImageURL = ""
    private var defaultURL = "https://source.unsplash.com/random"
    
    var imageData: Data?
    var counterForCustomAppReview = UserDefaults.standard.integer(forKey: customAppReviewCountKey)
    private var counterForSystemAppReview = UserDefaults.standard.integer(forKey: systemAppReviewCountKey)
    private var getImageTappedCount = UserDefaults.standard.integer(forKey: getImageTappedCountKey)
    
    func getFirebaseImageURL() {
        db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            firebaseImageURL = snapshot.value as? String ?? defaultURL
        }
    }
    
    func getNewImage(keyword: String) {
        getImageTappedCount += 1
        UserDefaults.standard.set(getImageTappedCount, forKey: getImageTappedCountKey)
        
        if keyword.isEmpty {
            guard let url = URL(string: firebaseImageURL) else { return }
            self.imageData = try? Data(contentsOf: url)
            
        } else {
            let keywordURL = "https://source.unsplash.com/featured/?\(keyword)"
            guard let imageURL = URL(string: keywordURL) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
        }
        
        setWidget(imageData: imageData)
        
        // for Firebase
        let locale = TimeZone.current.identifier
        
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.db
            .child("getImage")
            .child(user)
            .setValue(["locale": locale, "count": String(getImageTappedCount)])
    }
    
    private func setWidget(imageData: Data?) {
        UserDefaults.standard.set(imageData, forKey: widgetDataKey)
        UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(imageData, forKeyPath: "widgetDataKey")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func checkDeviceModel() -> Bool {
        print("😚😚😚😚 \(UIDevice.modelName)")
        
        switch UIDevice.modelName {
        case "Simulator iPhone 14 Pro", "Simulator iPhone 14 Pro Max":
            return true
        case "iPhone 14 Pro", "iPhone 14 Pro Max":
            return true
        default:
            return false
        }
    }
    
    func checkSystemAppReview() {
        counterForSystemAppReview += 1
        UserDefaults.standard.set(counterForSystemAppReview, forKey: systemAppReviewCountKey)
        
        if counterForSystemAppReview >= 35 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            counterForSystemAppReview = 0
        }
    }
    
    func checkCustomAppReview() -> Bool {
        counterForCustomAppReview += 1
        UserDefaults.standard.set(counterForCustomAppReview, forKey: customAppReviewCountKey)
        print(counterForCustomAppReview)
        
        let infoDictionaryKey = kCFBundleVersionKey as String
        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
            print("Expected to find a bundle version in the info dictionary")
            return true
        }
        
        let lastVersion = UserDefaults.standard.string(forKey: lastVersionKey)
        
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
