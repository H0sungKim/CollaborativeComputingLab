//
//  ChatDTO.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Foundation

public struct ChatDTO: DTO {
    let name: String?
    let message: String?
    
    init(name: String?, message: String?) {
        self.name = name
        self.message = message
    }
    
    package init(entity: ChatEntity) {
        self.name = entity.name
        self.message = entity.message
    }
    
    package var entity: ChatEntity {
        return ChatEntity(
            name: name ?? "",
            message: message ?? ""
        )
    }
}
