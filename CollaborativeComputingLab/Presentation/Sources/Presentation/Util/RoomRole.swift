//
//  RoomRole.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.12.
//

import Domain

import Foundation

public enum RoomRole: Int, Sendable {
    case instructor = 0
    case student = 1
    
    var streamMode: StreamMode {
        switch self {
        case .instructor:
            return .publish
        case .student:
            return .play
        }
    }
}
