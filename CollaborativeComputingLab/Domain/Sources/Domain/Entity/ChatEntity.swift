//
//  ChatEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation

public struct ChatEntity: Entity {
    public let sender: String
    public let message: String
    
    public init(sender: String, message: String) {
        self.sender = sender
        self.message = message
    }
}
