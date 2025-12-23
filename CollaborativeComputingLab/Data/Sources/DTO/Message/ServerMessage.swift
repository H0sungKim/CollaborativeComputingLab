//
//  ServerMessage.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Domain

import Foundation

package enum ServerMessage {
    case availableRooms(RoomListDTO)
    case participantUpdated(ParticipantListDTO)
    case newChat(ChatDTO)
    case roomClosed
    
    enum ServerMessageType: String {
        case availableRooms
        case participantUpdated
        case newChat
        case roomClosed
    }
}

extension ServerMessage: Codable {
    package init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch ServerMessageType(rawValue: type) {
        case .availableRooms:
            self = .availableRooms(try container.decode(RoomListDTO.self, forKey: .payload))
        case .participantUpdated:
            self = .participantUpdated(try container.decode(ParticipantListDTO.self, forKey: .payload))
        case .newChat:
            self = .newChat(try container.decode(ChatDTO.self, forKey: .payload))
        case .roomClosed:
            self = .roomClosed
        case .none:
            throw DecodeError.unknownType
        }
    }
    
    package func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .availableRooms(let roomListDTO):
            try container.encode(roomListDTO, forKey: .payload)
            try container.encode(ServerMessageType.availableRooms.rawValue, forKey: .type)
        case .participantUpdated(let participantListDTO):
            try container.encode(participantListDTO, forKey: .payload)
            try container.encode(ServerMessageType.participantUpdated.rawValue, forKey: .type)
        case .newChat(let chatDTO):
            try container.encode(chatDTO, forKey: .payload)
            try container.encode(ServerMessageType.newChat.rawValue, forKey: .type)
        case .roomClosed:
            try container.encode(ServerMessageType.roomClosed.rawValue, forKey: .type)
        }
    }
    
    enum DecodeError: Error {
        case unknownType
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
}
