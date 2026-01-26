//
//  ChatUseCase.swift
//  Domain
//
//  Created by 김호성 on 2025.04.28.
//

import Combine
import Foundation

import Entity
import Repository

public protocol ChatUseCase {
    var chatStream: AnyPublisher<ChatEntity, Never> { get }
    
    func sendChat(messageEntity: MessageEntity)
    func connectWebSocket()
}

public final class DefaultChatUseCase: ChatUseCase {
    
    private let chatRepository: ChatRepository
    
    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    public var chatStream: AnyPublisher<ChatEntity, Never> {
        return chatRepository.chatStream
    }
    
    public func sendChat(messageEntity: MessageEntity) {
        chatRepository.sendChat(messageEntity: messageEntity)
    }
    
    public func connectWebSocket() {
        chatRepository.connectWebSocket()
    }
}
