//
//  FileParser.swift
//  Meteor
//
//  Created by 장기화 on 4/16/24.
//

import Foundation

struct FileParser {
    static var teamID: String {
        guard let file = Bundle.main.path(forResource: "IDList", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["TEAM_ID"] as? String else {
            fatalError()
        }
        return key
    }
    
    static var keyID: String {
        guard let file = Bundle.main.path(forResource: "IDList", ofType: "plist") else { return "" }
        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["KEY_ID"] as? String else {
            fatalError()
        }
        return key
    }
    
    /// Convert PEM format .p8 file to DER-encoded ASN.1 data
    static func parse() -> P8Payload? {
        guard let path = Bundle.main.path(forResource: "AuthKey", ofType: "p8") else { return nil }
        let pathURL = URL(filePath: path)
        guard let content = try? String(contentsOf: pathURL) else { return nil }
        let keyContent = content.split(separator: "\n")
            .filter { !($0.hasPrefix("-----") && $0.hasSuffix("-----")) }
            .joined(separator: "")
        
        return P8Payload(keyContent)
    }
}
