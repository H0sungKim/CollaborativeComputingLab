//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import Combine

public protocol ChatViewModelInput {
    func sendMessage(message: String)
}

public protocol ChatViewModelOutput {
    var chats: CurrentValueSubject<[String], Never> { get }
}

public protocol ChatViewModel: ChatViewModelInput, ChatViewModelOutput { }

public class DefaultChatViewModel: ChatViewModel {
    
    public var chats: CurrentValueSubject<[String], Never> = .init([])
    
    private let chatService: ChatService
    
    public init(chatService: ChatService) {
        self.chatService = chatService
        receive()
    }
    
    private func receive() {
        chatService.webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    break
                case .string(let string):
                    self?.chats.value.append(string)
                @unknown default:
                    break
                }
            case .failure(let error):
                print(error)
            }
            self?.receive()
        })
    }
    
    public func sendMessage(message: String) {
        chatService.send(message: message)
    }
}
