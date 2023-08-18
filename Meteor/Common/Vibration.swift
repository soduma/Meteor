//
//  Vibration.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import UIKit

enum VibrationType {
    case rigid
    case medium
    case success
    case warning
    case error
}

func makeVibration(type: VibrationType) {
    if UserDefaults.standard.bool(forKey: hapticStateKey) {
        switch type {
        case .rigid:
            return UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            
        case .medium:
            return UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
        case .success:
            return UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        case .warning:
            return UINotificationFeedbackGenerator().notificationOccurred(.warning)
            
        case .error:
            return UINotificationFeedbackGenerator().notificationOccurred(.error)
        }
    }
}
