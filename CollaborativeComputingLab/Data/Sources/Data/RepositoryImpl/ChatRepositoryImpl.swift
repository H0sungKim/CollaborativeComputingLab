//
//  ChatRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Foundation
import Combine

public final class DefaultChatRepository: ChatRepository {
    
    private let webSocketService: WebSocketService
    
    public var chatStream: AnyPublisher<ChatEntity, Error> {
        return webSocketService.chatStream
            .map(\.entity)
            .eraseToAnyPublisher()
    }
    
    public init(webSocketService: WebSocketService) {
        self.webSocketService = webSocketService
    }
    
    public func sendChat(chatEntity: ChatEntity) {
        webSocketService.send(chatDTO: ChatDTO(entity: chatEntity))
    }
    
    public func connectWebSocket() {
        webSocketService.connectWebSocket()
    }
    
    public func disconnectWebSocket() {
        webSocketService.disconnectWebSocket()
    }
}
