//
//  RoomEntranceEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

public struct RoomEntranceEntity: Codable {
    public let id: String
    public let userName: String
    
    public init(id: String, userName: String) {
        self.id = id
        self.userName = userName
    }
}
