//
//  OnboardingViewModel.swift
//  Meteor
//
//  Created by 장기화 on 5/4/24.
//

import Foundation
import UserNotifications

@Observable
class OnboardingViewModel {
    var isPresented = false
    
    func requestAuth() async {
        let center = UNUserNotificationCenter.current()
        do {
            try await center.requestAuthorization(options: [.alert, .sound])
        } catch {
            print(error.localizedDescription)
        }
        
        isPresented = true
    }
}
