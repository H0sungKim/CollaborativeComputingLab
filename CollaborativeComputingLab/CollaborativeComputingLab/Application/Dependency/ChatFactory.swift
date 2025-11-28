//
//  ChatFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.04.
//

import Data
import Domain
import Presentation

import Foundation

protocol ChatFactory {
    func makeChatService() -> ChatService
    
    func makeChatRepository() -> ChatRepository
    func makeChatRepository(chatService: ChatService) -> ChatRepository
    
    func makeChatUseCase() -> ChatUseCase
    func makeChatUseCase(chatRepository: ChatRepository) -> ChatUseCase
    
    func makeChatViewModel() -> ChatViewModel
    func makeChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel
}

extension ChatFactory {
    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(chatService: makeChatService())
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
