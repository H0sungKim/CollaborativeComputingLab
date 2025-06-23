//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation

public enum WebSocketError: Error {
    case nonDataMessage(message: String)
    case unknownTypeMessage
    case messageReceiveFailed(error: Error)
}

extension WebSocketError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .nonDataMessage(let message):
            return "Expected a Data message, but received a String: \(message)"
        case .unknownTypeMessage:
            return "Received a message of unknown type."
        case .messageReceiveFailed(let error):
            return "Failed to receive message: \(error.localizedDescription)"
        }
    }
}
