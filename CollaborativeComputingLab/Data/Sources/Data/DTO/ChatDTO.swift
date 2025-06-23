//
//  ChatDTO.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Foundation

public struct ChatDTO: DTO {
    let sender: String?
    let message: String?
    
    init(sender: String?, message: String?) {
        self.sender = sender
        self.message = message
    }
    
    init(entity: ChatEntity) {
        self.sender = entity.sender
        self.message = entity.message
    }
    
    var entity: ChatEntity {
        get {
            return ChatEntity(
                sender: self.sender ?? "",
                message: self.message ?? ""
            )
        }
    }
}
