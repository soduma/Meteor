//
//  APNS.swift
//  Meteor
//
//  Created by 장기화 on 4/16/24.
//

import Foundation

class APNSManager {
    enum APNS: String {
        case sandbox
        case production
    }
    
    private var hostAddOn: String? {
#if RELEASE
        return nil
#else
        return APNS.sandbox.rawValue
#endif
    }
    
    func urlRequest(authenticationToken: String,
                    deviceToken: String,
                    payload: String) -> URLRequest? {
        guard let url = urlComponents(deviceToken: deviceToken).url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("bearer \(authenticationToken)", forHTTPHeaderField: "authorization")
        request.setValue("com.soduma.Meteor.push-type.liveactivity", forHTTPHeaderField: "apns-topic")
        request.setValue("10", forHTTPHeaderField: "apns-priority")
        request.setValue("liveactivity", forHTTPHeaderField: "apns-push-type")
        
        request.httpBody = payload.data(using: .utf8)
        return request
    }
    
    private func urlComponents(deviceToken: String) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = ["api", hostAddOn, "push.apple.com"]
            .compactMap { $0 }
            .joined(separator: ".")
        urlComponents.path = "/3/device/\(deviceToken)"
        return urlComponents
    }
}
