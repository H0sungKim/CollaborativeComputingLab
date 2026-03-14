//
//  WebSocketFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.01.28.
//

import Foundation

import Data

protocol WebSocketFactory {
    var webSocket: WebSocket { get set }
    
    func makeWebSocket() -> WebSocket
}

extension WebSocketFactory {
    func makeWebSocket() -> WebSocket {
        return webSocket
    }
}
