//
//  RoomExitDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Domain

import Foundation

public struct RoomExitDTO: DTO {
    let id: String?
    
    init(id: String?) {
        self.id = id
    }
    
    package init(entity: RoomExitEntity) {
        self.id = entity.id
    }
    
    package var entity: RoomExitEntity {
        return RoomExitEntity(id: id ?? "")
    }
}
