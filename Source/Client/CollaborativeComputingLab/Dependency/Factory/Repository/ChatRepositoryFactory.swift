//
//  ChatRepositoryFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.01.28.
//

import Foundation

import Data
import Domain

protocol ChatRepositoryFactory: ChatServiceFactory {
    func makeChatRepository() -> ChatRepository
}

extension ChatRepositoryFactory {
    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(chatService: makeChatService())
    }
}
