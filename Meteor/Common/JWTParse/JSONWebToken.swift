//
//  JSONWebToken.swift
//  Meteor
//
//  Created by 장기화 on 4/16/24.
//

import Foundation

struct JSONWebToken: Codable {
    let token: String
    
    private let header: Header
    private let claims: Claims
    
    init(keyID: String,
         teamID: String,
         p8Payload: P8Payload) throws {
        header = Header(keyID: keyID)
        let oldDate = UserDefaults.standard.integer(forKey: UserDefaultsKeys.requestedDateKey)
        let newDate = Int(Date().timeIntervalSince1970.rounded())
        
        let isExpired = newDate > (oldDate + 20*60)
        guard isExpired else {
            claims = Claims(teamID: teamID, issueDate: oldDate)
            guard let token = UserDefaults.standard.string(forKey: UserDefaultsKeys.JWTokenKey) else {
                throw JSONWebTokenError.invalidToken }
            self.token = token
            return
        }
        
        claims = Claims(teamID: teamID, issueDate: newDate)
        let digest = try Self.digest(header: header, claims: claims)
        let ellipticCurveKey = try EllipticCurveKey(p8Payload).key
        let signature = try ellipticCurveKey.es256Sign(digest: digest)
        token = [digest, signature].joined(separator: ".")
        UserDefaults.standard.set(newDate, forKey: UserDefaultsKeys.requestedDateKey)
        UserDefaults.standard.set(token, forKey: UserDefaultsKeys.JWTokenKey)
    }
}

private extension JSONWebToken {
    static func digest(header: Header, claims: Claims) throws -> String {
        let headerString = try JSONEncoder().encode(header.self).base64EncodedURLString()
        let claimsString = try JSONEncoder().encode(claims.self).base64EncodedURLString()
        return [headerString, claimsString].joined(separator: ".")
    }
}

private extension JSONWebToken {
    struct Header: Codable {
        
        let algorithm: String = "ES256"
        let keyID: String
        
        enum CodingKeys: String, CodingKey {
            case algorithm = "alg"
            case keyID = "kid"
        }
    }
    
    struct Claims: Codable {
        let teamID: String
        let issueDate: Int
        
        enum CodingKeys: String, CodingKey {
            case teamID = "iss"
            case issueDate = "iat"
        }
    }
}

enum JSONWebTokenError: Error {
    case digestDataCorruption, keyNotSupportES256Signing, invalidASN1, invalidP8, invalidToken
}
