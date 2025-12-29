//
//  RoomListEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

public struct RoomEntity: Entity, Hashable, Sendable {
    public let id: String
    public let participants: [String]
    
    public init(id: String, participants: [String]) {
        self.id = id
        self.participants = participants
    }
}
