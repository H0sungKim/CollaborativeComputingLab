//
//  WebSocketClient.swift
//  Server
//
//  Created by 김호성 on 2025.06.24.
//

import Foundation
import Network

final class WebSocketClient: Hashable, Equatable {
    
    let id: String
    var name: String?
    let connection: NWConnection
    
    init(connection: NWConnection) {
        self.connection = connection
        self.id = UUID().uuidString
    }
    
    static func == (lhs: WebSocketClient, rhs: WebSocketClient) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
