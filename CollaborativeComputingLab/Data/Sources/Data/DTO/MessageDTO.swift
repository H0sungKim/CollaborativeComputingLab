//
//  MessageDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Domain

import Foundation

public struct MessageDTO: DTO {
    let message: String?
    
    init(message: String?) {
        self.message = message
    }
    
    init(entity: MessageEntity) {
        self.message = entity.message
    }
    
    var entity: MessageEntity {
        return MessageEntity(message: message ?? "")
    }
}
