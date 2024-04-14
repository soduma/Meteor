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
    private let db = Database.database().reference()
    private var firebaseImageURL = ""
    static let defaultURL = "https://source.unsplash.com/random"
    
    var liveColor = LiveColor.red
    
    func getFirebaseImageURL() {
        db.child(unsplash).observeSingleEvent(of: .value) { [weak self] snapshot in
            self?.firebaseImageURL = snapshot.value as? String ?? SettingsViewModel.defaultURL
        }
    }
    
    func getNewImage(keyword: String) async -> Data? {
        var imageData: Data?
        var counterForGetNewImageTapped = UserDefaults.standard.integer(forKey: UserDefaultsKeys.getNewImageTappedCountKey)
        counterForGetNewImageTapped += 1
        UserDefaults.standard.set(counterForGetNewImageTapped, forKey: UserDefaultsKeys.getNewImageTappedCountKey)
        
        do {
            if keyword.isEmpty {
                guard let imageURL = URL(string: firebaseImageURL) else { return nil }
                (imageData, _) = try await URLSession.shared.data(from: imageURL)
                
            } else {
                let url = "https://source.unsplash.com/featured/?\(keyword)"
                guard let imageURL = URL(string: url) else { return nil }
                (imageData, _) = try await URLSession.shared.data(from: imageURL)
                
            }
        } catch {
            print(error.localizedDescription)
        }
        
        setWidget(imageData: imageData)
        
#if RELEASE
        guard let user = await UIDevice.current.identifierForVendor?.uuidString else { return nil }
        let locale = TimeZone.current.identifier
        let version = getCurrentVersion().replacingOccurrences(of: ".", with: "_")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let date = dateFormatter.string(from: Date())
        
        do {
            try await self.db
                .child(version)
                .child("1_getImage")
                .child(locale)
                .child(user)
                .child(date)
                .setValue(["count": String(counterForGetNewImageTapped), "keyword": keyword])
        } catch {
            print(error.localizedDescription)
        }
#endif
        return imageData
    }
    
    func setWidget(imageData: Data?) {
        UserDefaults.standard.set(imageData, forKey: UserDefaultsKeys.widgetDataKey)
        UserDefaults(suiteName: "group.com.soduma.Meteor")?.setValue(imageData, forKeyPath: "widgetDataKey")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// AOD가 있는 모델만
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
    
    func getCurrentVersion() -> String {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else { return "" }
        return version
    }
    
    func executeAppReviews() -> Bool {
        systemAppReview()
        return customAppReview()
    }
    
    private func systemAppReview() {
        var counterForSystemAppReview = UserDefaults.standard.integer(forKey: UserDefaultsKeys.systemAppReviewCountKey)
        counterForSystemAppReview += 1
        
        if counterForSystemAppReview >= systemReviewLimit {
            guard let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
            SKStoreReviewController.requestReview(in: scene)
            counterForSystemAppReview = 0
            UserDefaults.standard.set(counterForSystemAppReview, forKey: UserDefaultsKeys.systemAppReviewCountKey)
        }
    }
    
    private func customAppReview() -> Bool {
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
}
