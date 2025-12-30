//
//  ChatDTO.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Foundation

import Domain

public struct ChatDTO: Codable {
    public let name: String?
    public let message: String?
    
    public init(name: String?, message: String?) {
        self.name = name
        self.message = message
    }
}

// MARK: - Entity Mapping
extension ChatDTO {
    public init(entity: ChatEntity) {
        self.name = entity.name
        self.message = entity.message
    }
    
    public var entity: ChatEntity {
        return ChatEntity(
            name: name ?? "",
            message: message ?? ""
        )
    }
}
