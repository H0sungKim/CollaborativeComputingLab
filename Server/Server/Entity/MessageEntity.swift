//
//  MessageEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

public struct MessageEntity: Entity {
    public let message: String
    
    public init(message: String) {
        self.message = message
    }
}
