//
//  MessageDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

import Domain

public struct MessageDTO: DTO {
    public let message: String?
    
    public init(message: String?) {
        self.message = message
    }
    
    public init(entity: MessageEntity) {
        self.message = entity.message
    }
    
    public var entity: MessageEntity {
        return MessageEntity(message: message ?? "")
    }
}
