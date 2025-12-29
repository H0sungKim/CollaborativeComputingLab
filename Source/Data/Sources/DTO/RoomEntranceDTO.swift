//
//  RoomEntranceDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

import Domain

public struct RoomEntranceDTO: DTO {
    public let id: String?
    public let userName: String?
    
    public init(id: String?, userName: String?) {
        self.id = id
        self.userName = userName
    }
    
    public init(entity: RoomEntranceEntity) {
        self.id = entity.id
        self.userName = entity.userName
    }
    
    public var entity: RoomEntranceEntity {
        return RoomEntranceEntity(
            id: id ?? "",
            userName: userName ?? ""
        )
    }
}
