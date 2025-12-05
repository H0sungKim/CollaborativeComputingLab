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
    func buildChatRepository() -> ChatRepository
    func buildChatRepository(chatService: ChatService) -> ChatRepository
    
    func buildChatUseCase() -> ChatUseCase
    func buildChatUseCase(chatRepository: ChatRepository) -> ChatUseCase
    
    func buildChatViewModel() -> ChatViewModel
    func buildChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel
}

extension ChatFactory {
    func buildChatRepository(chatService: ChatService) -> ChatRepository {
        return DefaultChatRepository(chatService: chatService)
    }
    
    func buildChatUseCase() -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: buildChatRepository())
    }
    func buildChatUseCase(chatRepository: ChatRepository) -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: chatRepository)
    }
    
    func buildChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: buildChatUseCase())
    }
    func buildChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: chatUseCase)
    }
}
