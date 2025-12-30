//
//  RoomExitDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

import Domain

public struct RoomExitDTO: Codable {
    public let id: String?
    
    public init(id: String?) {
        self.id = id
    }
}

// MARK: - Entity Mapping
extension RoomExitDTO {
    public init(entity: RoomExitEntity) {
        self.id = entity.id
    }
    
    public var entity: RoomExitEntity {
        return RoomExitEntity(id: id ?? "")
    }
}
