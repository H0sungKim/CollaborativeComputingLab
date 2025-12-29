//
//  ChatRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.04.28.
//

import DTO
import Networking

import Domain

import Combine
import Foundation

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
