//
//  ParticipantListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

import Domain

public struct ParticipantListDTO: Codable {
    
    public let participants: [ParticipantDTO]?
    
    public init(participants: [ParticipantDTO]?) {
        self.participants = participants
    }
}

extension ParticipantListDTO {
    public struct ParticipantDTO: Codable {
        public let name: String?
        
        public init(name: String?) {
            self.name = name
        }
    }
}

// MARK: - Entity Mapping
extension ParticipantListDTO {
    public init(entities: [ParticipantEntity]) {
        self.participants = entities.map({ ParticipantDTO(entity: $0) })
    }
    
    public var entities: [ParticipantEntity] {
        return participants?.map(\.entity) ?? []
    }
}

extension ParticipantListDTO.ParticipantDTO {
    public init(entity: ParticipantEntity) {
        self.name = entity.name
    }
    
    public var entity: ParticipantEntity {
        return ParticipantEntity(name: name ?? "")
    }
}
