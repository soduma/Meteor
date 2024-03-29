//
//  SettingsViewModel.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import Foundation
import StoreKit
import WidgetKit
import FirebaseDatabase

enum LiveColor: Int { // UserDefaults 저장을 위해서 Int 처리
    case red = 0
    case black = 1
    case clear = 2
}

class SettingsViewModel {
    static let defaultURL = "https://source.unsplash.com/random"
    private var firebaseImageURL = ""
    private let db = Database.database().reference()
    
    var keywordText = ""
    var liveColor = LiveColor.red
    var imageData: Data?
    
    func getFirebaseImageURL() {
        db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.firebaseImageURL = snapshot.value as? String ?? SettingsViewModel.defaultURL
        }
    }
    
    func getNewImage(keyword: String) {
        var counterForGetNewImageTapped = UserDefaults.standard.integer(forKey: UserDefaultsKeys.getNewImageTappedCountKey)
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
        UserDefaults.standard.set(counterForGetNewImageTapped, forKey: UserDefaultsKeys.getNewImageTappedCountKey)
        
#if RELEASE
        // for Firebase
        guard let user = UIDevice.current.identifierForVendor?.uuidString else { return }
        let locale = TimeZone.current.identifier
        self.db
            .child("getImage")
            .child(user)
            .setValue(["locale": locale, "count": String(counterForGetNewImageTapped)])
#endif
    }
    
    func setWidget(imageData: Data?) {
        UserDefaults.standard.set(imageData, forKey: UserDefaultsKeys.widgetDataKey)
        UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(imageData, forKeyPath: "widgetDataKey")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func checkDeviceModel() -> Bool {
        print("😚😚😚😚 \(UIDevice.modelName)")
        
        switch UIDevice.modelName {
        case "Simulator iPhone 14 Pro", "Simulator iPhone 14 Pro Max",
            "Simulator iPhone 15 Pro", "Simulator iPhone 15 Pro Max":
            return true
        case "iPhone 14 Pro", "iPhone 14 Pro Max",
            "iPhone 15 Pro", "iPhone 15 Pro Max":
            return true
        default:
            return false
        }
    }
    
    func changeAppearance(lightMode: Bool, darkMode: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        
        if lightMode == true {
            window?.overrideUserInterfaceStyle = .light
        } else if darkMode == true {
            window?.overrideUserInterfaceStyle = .dark
        } else {
            window?.overrideUserInterfaceStyle = .unspecified
        }
        
        UserDefaults.standard.set(lightMode, forKey: UserDefaultsKeys.lightStateKey)
        UserDefaults.standard.set(darkMode, forKey: UserDefaultsKeys.darkStateKey)
    }
    
    func systemAppReview() {
        var counterForSystemAppReview = UserDefaults.standard.integer(forKey: UserDefaultsKeys.systemAppReviewCountKey)
        counterForSystemAppReview += 1
        
        if counterForSystemAppReview >= systemReviewLimit {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
            counterForSystemAppReview = 0
            UserDefaults.standard.set(counterForSystemAppReview, forKey: UserDefaultsKeys.systemAppReviewCountKey)
        }
    }
    
    func customAppReview() -> Bool {
        var counterForCustomAppReview = UserDefaults.standard.integer(forKey: UserDefaultsKeys.customAppReviewCountKey)
        counterForCustomAppReview += 1
        
        UserDefaults.standard.set(counterForCustomAppReview, forKey: UserDefaultsKeys.customAppReviewCountKey)
        print(counterForCustomAppReview)
                
        let lastVersion = UserDefaults.standard.string(forKey: UserDefaultsKeys.lastVersionKey)
        print(lastVersion ?? "")
        
        if lastVersion == nil && counterForCustomAppReview >= customReviewLimit {
            return true
        } else {
            return false
        }
    }
    
    func getCurrentVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
}
