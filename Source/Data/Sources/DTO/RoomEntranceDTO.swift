//
//  RoomEntranceDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Domain

import Foundation

public struct RoomEntranceDTO: DTO {
    let id: String?
    let userName: String?
    
    init(id: String?, userName: String?) {
        self.id = id
        self.userName = userName
    }
    
    package init(entity: RoomEntranceEntity) {
        self.id = entity.id
        self.userName = entity.userName
    }
    
    package var entity: RoomEntranceEntity {
        return RoomEntranceEntity(
            id: id ?? "",
            userName: userName ?? ""
        )
    }
}
