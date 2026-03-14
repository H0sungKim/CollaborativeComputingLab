//
//  ChatServiceFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.01.28.
//

import Foundation

import Data

protocol ChatServiceFactory: WebSocketFactory {
    func makeChatService() -> ChatService
}

extension ChatServiceFactory {
    func makeChatService() -> ChatService {
        return DefaultChatService(webSocket: makeWebSocket())
    }
}
