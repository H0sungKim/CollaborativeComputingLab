//
//  AppConfig.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.12.20.
//

import Foundation

enum AppConfig {
    static let uri: String = {
        guard let file = Bundle.main.path(forResource: "Secret", ofType: "plist") else { fatalError("Secret.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("Secret.plist not found.") }
        guard let key = resource["uri"] as? String else { fatalError("uri not found.") }
        return key
    }()
}
