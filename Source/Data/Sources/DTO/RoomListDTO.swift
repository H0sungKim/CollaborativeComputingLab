//
//  RoomListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

import Domain

public struct RoomListDTO: Codable {
    
    public let rooms: [RoomDTO]?
    
    public init(rooms: [RoomDTO]?) {
        self.rooms = rooms
    }
}

extension RoomListDTO {
    public struct RoomDTO: Codable {
        public let id: String?
        public let participants: [String]?
        
        public init(id: String?, participants: [String]?) {
            self.id = id
            self.participants = participants
        }
    }
}

// MARK: - Entity Mapping
extension RoomListDTO {
    public init(entities: [RoomEntity]) {
        self.rooms = entities.map({ RoomDTO(entity: $0) })
    }
    
    public var entities: [RoomEntity] {
        return rooms?.map(\.entity) ?? []
    }
}

extension RoomListDTO.RoomDTO {
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
