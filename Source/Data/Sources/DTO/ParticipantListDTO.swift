//
//  ParticipantListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

import Domain

public struct ParticipantListDTO: MultipleDTO {
    
    public struct ParticipantDTO: DTO {
        public let name: String?
        
        public init(name: String?) {
            self.name = name
        }
        
        public init(entity: ParticipantEntity) {
            self.name = entity.name
        }
        
        public var entity: ParticipantEntity {
            return ParticipantEntity(name: name ?? "")
        }
    }
    
    public let participants: [ParticipantDTO]?
    
    public init(participants: [ParticipantDTO]?) {
        self.participants = participants
    }
    
    public init(entities: [ParticipantEntity]) {
        self.participants = entities.map({ ParticipantDTO(entity: $0) })
    }
    
    public var entities: [ParticipantEntity] {
        return participants?.map(\.entity) ?? []
    }
}
