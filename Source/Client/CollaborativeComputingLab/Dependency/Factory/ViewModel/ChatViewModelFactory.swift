//
//  ChatViewModelFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.03.12.
//

import Foundation

import Presentation

protocol ChatViewModelFactory: ChatUseCaseFactory {
    func makeChatViewModel() -> ChatViewModel
}

extension ChatViewModelFactory {
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: makeChatUseCase())
    }
}
