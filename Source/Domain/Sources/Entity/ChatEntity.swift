//
//  ChatEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation

public struct ChatEntity: Codable, Sendable, Equatable, Hashable {
    public let name: String
    public let message: String
    
    public init(name: String, message: String) {
        self.name = name
        self.message = message
    }
}
