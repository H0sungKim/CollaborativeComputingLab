//
//  ChatUseCaseFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.01.31.
//

import Foundation

import Domain

protocol ChatUseCaseFactory: ChatRepositoryFactory {
    func makeChatUseCase() -> ChatUseCase
}

extension ChatUseCaseFactory {
    func makeChatUseCase() -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: makeChatRepository())
    }
}
