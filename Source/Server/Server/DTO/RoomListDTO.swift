//
//  RoomListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

public struct RoomListDTO: MultipleDTO {
    
    struct RoomDTO: DTO {
        let id: String?
        let participants: [String]?
        
        init(id: String?, participants: [String]?) {
            self.id = id
            self.participants = participants
        }
        
        init(entity: RoomEntity) {
            self.id = entity.id
            self.participants = entity.participants
        }
        
        var entity: RoomEntity {
            return RoomEntity(
                id: id ?? "",
                participants: participants ?? []
            )
        }
    }
    
    let rooms: [RoomDTO]?
    
    init(rooms: [RoomDTO]?) {
        self.rooms = rooms
    }
    
    init(entities: [RoomEntity]) {
        self.rooms = entities.map({ RoomDTO(entity: $0) })
    }
    
    var entities: [RoomEntity] {
        return rooms?.map(\.entity) ?? []
    }
}
