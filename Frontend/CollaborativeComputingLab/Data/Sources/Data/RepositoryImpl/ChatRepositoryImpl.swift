//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Domain

import Foundation
import Combine

public class DefaultChatRepository: ChatRepository {
    
    private let chatService: ChatService
    
    public init(chatService: ChatService) {
        self.chatService = chatService
    }
    
    public var chatStream: AnyPublisher<ChatEntity, any Error> {
        return chatService.chatStream
            .map(\.entity)
            .eraseToAnyPublisher()
    }
    
    public func sendChat(chatEntity: ChatEntity) {
        chatService.send(chatDTO: ChatDTO(entity: chatEntity))
    }
    
    public func connectWebSocket() {
        chatService.connectWebSocket()
    }
    
    public func disconnectWebSocket() {
        chatService.disconnectWebSocket()
    }
}
