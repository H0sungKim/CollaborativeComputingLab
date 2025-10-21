//
//  CatDIContainer.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.04.
//

import Data
import Domain
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
