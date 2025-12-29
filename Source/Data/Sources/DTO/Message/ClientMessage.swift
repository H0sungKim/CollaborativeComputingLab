//
//  ClientMessage.swift
//  Data
//
//  Created by 김호성 on 2025.06.26.
//

import Foundation

public enum ClientMessage {
    case requestRoomList
    case enterRoom(RoomEntranceDTO)
    case leaveRoom(RoomExitDTO)
    case sendChat(MessageDTO)
    
    enum ClientMessageType: String {
        case requestRoomList
        case enterRoom
        case leaveRoom
        case sendChat
    }
}

extension ClientMessage: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        switch ClientMessageType(rawValue: type) {
        case .requestRoomList:
            self = .requestRoomList
        case .enterRoom:
            self = .enterRoom(try container.decode(RoomEntranceDTO.self, forKey: .payload))
        case .leaveRoom:
            self = .leaveRoom(try container.decode(RoomExitDTO.self, forKey: .payload))
        case .sendChat:
            self = .sendChat(try container.decode(MessageDTO.self, forKey: .payload))
        case .none:
            throw DecodeError.unknownType
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .requestRoomList:
            try container.encode(ClientMessageType.requestRoomList.rawValue, forKey: .type)
        case .enterRoom(let roomEntranceDTO):
            try container.encode(roomEntranceDTO, forKey: .payload)
            try container.encode(ClientMessageType.enterRoom.rawValue, forKey: .type)
        case .leaveRoom(let roomExitDTO):
            try container.encode(roomExitDTO, forKey: .payload)
            try container.encode(ClientMessageType.leaveRoom.rawValue, forKey: .type)
        case .sendChat(let messageDTO):
            try container.encode(messageDTO, forKey: .payload)
            try container.encode(ClientMessageType.sendChat.rawValue, forKey: .type)
        }
    }
    
    enum DecodeError: Error {
        case unknownType
    }
    
    enum CodingKeys: String, CodingKey {
        case type, payload
    }
}
