//
//  SettingViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import Foundation
import StoreKit
import WidgetKit
import FirebaseDatabase

class SettingViewModel {
    private let db = Database.database().reference()
    private var firebaseImageURL = ""
    private var defaultURL = "https://source.unsplash.com/random"
    
    var imageData: Data?
//    var counterForCustomAppReview = UserDefaults.standard.integer(forKey: customAppReviewCountKey)
//    private var counterForSystemAppReview = UserDefaults.standard.integer(forKey: systemAppReviewCountKey)
//    private var counterForGetNewImageTapped = UserDefaults.standard.integer(forKey: getNewImageTappedCountKey)
    
    func getFirebaseImageURL() {
        db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let self = self else { return }
            firebaseImageURL = snapshot.value as? String ?? defaultURL
        }
    }
    
    func getNewImage(keyword: String) {
        var counterForGetNewImageTapped = UserDefaults.standard.integer(forKey: getNewImageTappedCountKey)
        counterForGetNewImageTapped += 1
        
        if keyword.isEmpty {
            guard let url = URL(string: firebaseImageURL) else { return }
            self.imageData = try? Data(contentsOf: url)
            
        } else {
            let keywordURL = "https://source.unsplash.com/featured/?\(keyword)"
            guard let imageURL = URL(string: keywordURL) else { return }
            self.imageData = try? Data(contentsOf: imageURL)
        }
        
        setWidget(imageData: imageData)
        
        UserDefaults.standard.set(counterForGetNewImageTapped, forKey: getNewImageTappedCountKey)
        
        // for Firebase
        let locale = TimeZone.current.identifier
        
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        self.db
            .child("getImage")
            .child(user)
            .setValue(["locale": locale, "count": String(counterForGetNewImageTapped)])
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
        var counterForSystemAppReview = UserDefaults.standard.integer(forKey: systemAppReviewCountKey)
        counterForSystemAppReview += 1
        
        if counterForSystemAppReview >= 100 {
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
            counterForSystemAppReview = 0
        }
        UserDefaults.standard.set(counterForSystemAppReview, forKey: systemAppReviewCountKey)
    }
    
    func checkCustomAppReview() -> Bool {
        var counterForCustomAppReview = UserDefaults.standard.integer(forKey: customAppReviewCountKey)
        counterForCustomAppReview += 1
        
//        let infoDictionaryKey = kCFBundleVersionKey as String
//        guard let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String else {
//            print("Expected to find a bundle version in the info dictionary")
//            return true
//        }
        
        UserDefaults.standard.set(counterForCustomAppReview, forKey: customAppReviewCountKey)
        print(counterForCustomAppReview)
        
//        let currentVersion = getCurrentVersion()
        
        let lastVersion = UserDefaults.standard.string(forKey: lastVersionKey)
        
        if counterForCustomAppReview >= 50 && getCurrentVersion() != lastVersion {
            return true
        } else {
            return false
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
