//
//  Room.swift
//  Server
//
//  Created by 김호성 on 2025.06.29.
//

import Foundation

final class Room {
    let id: String
    var instructor: WebSocketClient?
    
    var clients: [WebSocketClient] = []
    
    var isAvailable: Bool {
        if let instructor, !clients.isEmpty {
            return true
        } else {
            return false
        }
    }
    
    init(id: String, instructor: WebSocketClient) {
        self.id = id
        self.instructor = instructor
    }
    
    func addClient(_ client: WebSocketClient) {
        clients.append(client)
    }
    
    @discardableResult
    func removeClient(_ client: WebSocketClient) -> Bool {
        if client == instructor {
            instructor = nil
        }
        let oldCount = clients.count
        clients.removeAll(where: { $0 == client })
        return oldCount != clients.count
    }
    
    var roomEntity: RoomEntity {
        return RoomEntity(id: id, participants: clients.compactMap(\.name))
    }
}
