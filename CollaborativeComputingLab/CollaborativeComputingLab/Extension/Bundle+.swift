//
//  Bundle+Ext.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.07.
//

import Foundation

extension Bundle {
    var uri: String? {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { return nil }
        guard let resource = NSDictionary(contentsOfFile: file) else { return nil }
        guard let key = resource["uri"] as? String else { return nil }
        return key
    }
}
