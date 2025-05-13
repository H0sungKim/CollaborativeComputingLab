//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.12.
//

import Domain

import Foundation

public enum RoomRole: Int {
    case instructor = 0
    case student = 1
    
    var streamRole: StreamRole {
        switch self {
        case .instructor:
            return .publish
        case .student:
            return .play
        }
    }
    
    var isPDFHidden: Bool {
        switch self {
        case .instructor:
            return false
        case .student:
            return true
        }
    }
}
