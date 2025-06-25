//
//  CatDIContainer.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.04.
//

import Domain
import Data
import Presentation

import Foundation

protocol ChatDIProvider {
    func makeChatRepository() -> ChatRepository
    func makeChatRepository(chatService: ChatService) -> ChatRepository
    
    func makeChatUseCase() -> ChatUseCase
    func makeChatUseCase(chatRepository: ChatRepository) -> ChatUseCase
    
    func makeChatViewModel() -> ChatViewModel
    func makeChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel
}

class DefaultChatDIProvider: ChatDIProvider {
    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(chatService: DefaultChatService(webSocket: WebSocket(url: URL(string: "ws://\(Bundle.main.uri ?? ""):8080")!)))
    }
    func makeChatRepository(chatService: ChatService) -> ChatRepository {
        return DefaultChatRepository(chatService: chatService)
    }
    
    func makeChatUseCase() -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: makeChatRepository())
    }
    func makeChatUseCase(chatRepository: ChatRepository) -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: chatRepository)
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: makeChatUseCase())
    }
    func makeChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: chatUseCase)
    }
}
