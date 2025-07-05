//
//  ParticipantListDTO.swift
//  Data
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

public struct ParticipantListDTO: MultipleDTO {
    
    struct ParticipantDTO: DTO {
        let name: String?
        
        init(name: String?) {
            self.name = name
        }
        
        init(entity: ParticipantEntity) {
            self.name = entity.name
        }
        
        var entity: ParticipantEntity {
            return ParticipantEntity(name: name ?? "")
        }
    }
    
    let participants: [ParticipantDTO]?
    
    init(participants: [ParticipantDTO]?) {
        self.participants = participants
    }
    
    init(entities: [ParticipantEntity]) {
        self.participants = entities.map({ ParticipantDTO(entity: $0) })
    }
    
    var entities: [ParticipantEntity] {
        return participants?.map(\.entity) ?? []
    }
}
