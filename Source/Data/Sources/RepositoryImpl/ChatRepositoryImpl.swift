//
//  ChatRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import Combine
import Foundation

import Domain

import DTO
import Networking

public final class DefaultChatRepository: ChatRepository {
    
    private let chatService: ChatService
    
    public var chatStream: AnyPublisher<ChatEntity, Never> {
        return chatService.chatStream
            .map(\.entity)
            .eraseToAnyPublisher()
    }
    
    public init(chatService: ChatService) {
        self.chatService = chatService
    }
    
    public func sendChat(messageEntity: MessageEntity) {
        chatService.send(messageDTO: MessageDTO(entity: messageEntity))
    }
    
    public func connectWebSocket() {
        chatService.connectWebSocket()
    }
}
