//
//  ParticipantListEntity.swift
//  Domain
//
//  Created by 김호성 on 2025.06.27.
//

import Foundation

public struct ParticipantEntity: Entity {
    public let name: String
    
    public init(name: String) {
        self.name = name
    }
}
