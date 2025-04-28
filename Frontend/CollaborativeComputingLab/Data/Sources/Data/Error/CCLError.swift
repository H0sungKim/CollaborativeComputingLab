//
//  CCLError.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Foundation

public enum CCLError: Error {
    case dataFailed(string: String)
    case decodeFailed(string: String)
    case encodeFailed(string: String)
    
    var description: String {
        switch self {
        case .dataFailed(let string):
            return "Data Error - \(string)"
        case .decodeFailed(let string):
            return "Decode Error - \(string)"
        case .encodeFailed(let string):
            return "Encode Error - \(string)"
        }
    }
}
