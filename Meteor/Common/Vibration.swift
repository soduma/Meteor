//
//  Vibration.swift
//  Meteor
//
//  Created by 장기화 on 2023/08/07.
//

import UIKit
import AudioToolbox

enum VibrationType {
    case rigid
    case medium
    case success
    case error
    case big
}

func makeVibration(type: VibrationType) {
    if UserDefaults.standard.bool(forKey: VibrateState) {
        switch type {
        case .rigid:
            return UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
            
        case .medium:
            return UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            
        case .success:
            return UINotificationFeedbackGenerator().notificationOccurred(.success)
            
        case .error:
            return UINotificationFeedbackGenerator().notificationOccurred(.error)
            
        case .big:
            return                         AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
}
