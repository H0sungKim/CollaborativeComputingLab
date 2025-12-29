//
//  RoomExitDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Domain

import Foundation

public struct RoomExitDTO: DTO {
    public let id: String?
    
    public init(id: String?) {
        self.id = id
    }
    
    public init(entity: RoomExitEntity) {
        self.id = entity.id
    }
    
    public var entity: RoomExitEntity {
        return RoomExitEntity(id: id ?? "")
    }
}
