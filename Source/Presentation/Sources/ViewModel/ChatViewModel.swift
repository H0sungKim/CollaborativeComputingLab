//
//  ChatViewModel.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import Combine

import Domain

public protocol ChatViewModelInput {
    func sendChat(message: String)
    func connectWebSocket()
}

public protocol ChatViewModelOutput {
    var chats: CurrentValueSubject<[ChatEntity], Never> { get }
}

public protocol ChatViewModel: ChatViewModelInput, ChatViewModelOutput { }

public final class DefaultChatViewModel: ChatViewModel {
    
    public var chats: CurrentValueSubject<[ChatEntity], Never> = .init([])
    
    private let chatUseCase: ChatUseCase
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(chatUseCase: ChatUseCase) {
        self.chatUseCase = chatUseCase
        bind()
    }
    
    private func bind() {
        chatUseCase.chatStream
            .manageThread()
            .sinkHandledCompletion(receiveValue: { [weak self] chatEntity in
                self?.chats.value.append(chatEntity)
            })
            .store(in: &cancellable)
    }
    
    public func sendChat(message: String) {
        let messageEntity = MessageEntity(message: message)
        chatUseCase.sendChat(messageEntity: messageEntity)
    }
    
    public func connectWebSocket() {
        chatUseCase.connectWebSocket()
    }
}
