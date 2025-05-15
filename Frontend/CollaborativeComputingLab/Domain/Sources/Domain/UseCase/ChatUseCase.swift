//
//  ChatUseCase.swift
//  Domain
//
//  Created by 김호성 on 2025.04.28.
//

import Foundation
import Combine

public protocol ChatUseCase {
    var chatStream: AnyPublisher<ChatEntity, Error> { get }
    
    func sendChat(chatEntity: ChatEntity)
    func connectWebSocket()
    func disconnectWebSocket()
}

public final class DefaultChatUseCase: ChatUseCase {
    
    private let chatRepository: ChatRepository
    
    public init(chatRepository: ChatRepository) {
        self.chatRepository = chatRepository
    }
    
    public var chatStream: AnyPublisher<ChatEntity, any Error> {
        return chatRepository.chatStream
    }
    
    public func sendChat(chatEntity: ChatEntity) {
        chatRepository.sendChat(chatEntity: chatEntity)
    }
    
    public func connectWebSocket() {
        chatRepository.connectWebSocket()
    }
    
    public func disconnectWebSocket() {
        chatRepository.disconnectWebSocket()
    }
    
}
