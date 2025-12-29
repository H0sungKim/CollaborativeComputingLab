//
//  RoomListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Domain

import Foundation

public struct RoomListDTO: MultipleDTO {
    
    public struct RoomDTO: DTO {
        public let id: String?
        public let participants: [String]?
        
        public init(id: String?, participants: [String]?) {
            self.id = id
            self.participants = participants
        }
        
        public init(entity: RoomEntity) {
            self.id = entity.id
            self.participants = entity.participants
        }
        
        public var entity: RoomEntity {
            return RoomEntity(
                id: id ?? "",
                participants: participants ?? []
            )
        }
    }
    
    public let rooms: [RoomDTO]?
    
    public init(rooms: [RoomDTO]?) {
        self.rooms = rooms
    }
    
    public init(entities: [RoomEntity]) {
        self.rooms = entities.map({ RoomDTO(entity: $0) })
    }
    
    public var entities: [RoomEntity] {
        return rooms?.map(\.entity) ?? []
    }
}
