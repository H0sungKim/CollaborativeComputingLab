//
//  CatDIContainer.swift
//  CleanArchitectureMVVM
//
//  Created by 김호성 on 2025.03.04.
//

import Domain
import Data
import Presentation

import Foundation

protocol ChatDIProvider {
    func makeChatRepository() -> ChatRepository
    func makeChatRepository(webSocketService: WebSocketService) -> ChatRepository
    
    func makeChatUseCase() -> ChatUseCase
    func makeChatUseCase(chatRepository: ChatRepository) -> ChatUseCase
    
    func makeChatViewModel() -> ChatViewModel
    func makeChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel
}

class DefaultChatDIProvider: ChatDIProvider {
    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(webSocketService: DefaultWebSocketService())
    }
    func makeChatRepository(webSocketService: WebSocketService) -> ChatRepository {
        return DefaultChatRepository(webSocketService: webSocketService)
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
