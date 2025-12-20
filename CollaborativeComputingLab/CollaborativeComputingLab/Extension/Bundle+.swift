//
//  Bundle+Ext.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.07.
//

import Foundation

extension Bundle {
    var uri: String {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { fatalError("Secret.plist not found.") }
        guard let resource = NSDictionary(contentsOfFile: file) else { fatalError("Secret.plist not found.") }
        guard let key = resource["uri"] as? String else { fatalError("uri not found.") }
        return key
    }
}
