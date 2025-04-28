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
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(chatService: ChatService) {
        self.chatService = chatService
    }
    
    public var chatStream: AnyPublisher<ChatEntity, any Error> {
        return chatService.chatStream
            .map(\.entity)
            .eraseToAnyPublisher()
    }
    
    public func sendChat(chatEntity: ChatEntity) {
        if let encoded = try? JSONManager.shared.encode(codable: chatEntity) {
            chatService.send(message: encoded)
        }
    }

}
