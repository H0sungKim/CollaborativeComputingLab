//
//  File.swift
//  DataLayer
//
//  Created by 김호성 on 2025.03.07.
//

import Foundation

extension Bundle {
    var baseURL: String? {
        guard let file = self.path(forResource: "Secret", ofType: "plist") else { return nil }
        guard let resource = NSDictionary(contentsOfFile: file) else { return nil }
        guard let key = resource["base_URL"] as? String else { return nil }
        return key
    }
}
