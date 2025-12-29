//
//  MultipleDTO.swift
//  Data
//
//  Created by 김호성 on 2025.07.01.
//

import Domain

import Foundation

public protocol MultipleDTO: Codable {
    associatedtype EntityType: Entity
    
    var entities: [EntityType] { get }
    
    init(entities: [EntityType])
}
