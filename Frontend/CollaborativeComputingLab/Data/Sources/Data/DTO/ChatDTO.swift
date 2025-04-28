//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Foundation

public struct ChatDTO: Codable {
    let sender: String?
    let message: String?
}

extension ChatDTO: DTO {
    var entity: ChatEntity {
        get {
            return ChatEntity(
                sender: self.sender ?? "",
                message: self.message ?? ""
            )
        }
    }
}
