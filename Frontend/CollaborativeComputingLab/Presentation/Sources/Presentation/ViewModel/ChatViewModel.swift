//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Domain

import Foundation
import Combine

public protocol ChatViewModelInput {
    func sendChat(sender: String, message: String)
    func connectWebSocket()
    func disconnectWebSocket()
}

public protocol ChatViewModelOutput {
    var chats: CurrentValueSubject<[ChatEntity], Never> { get }
}

public protocol ChatViewModel: ChatViewModelInput, ChatViewModelOutput { }

public class DefaultChatViewModel: ChatViewModel {
    
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
    
    public func sendChat(sender: String, message: String) {
        let chatEntity = ChatEntity(sender: sender, message: message)
        chatUseCase.sendChat(chatEntity: chatEntity)
    }
    
    public func connectWebSocket() {
        chatUseCase.connectWebSocket()
    }
    
    public func disconnectWebSocket() {
        chatUseCase.disconnectWebSocket()
    }
}
