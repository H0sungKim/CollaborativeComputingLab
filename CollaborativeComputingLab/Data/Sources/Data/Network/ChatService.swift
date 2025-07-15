//
//  ChatService.swift
//  Data
//
//  Created by 김호성 on 2025.06.25.
//

import Domain

import Foundation
import Combine

public protocol ChatService: URLSessionWebSocketDelegate {
    var chatStream: PassthroughSubject<ChatDTO, Never> { get }
    
    func send(messageDTO: MessageDTO)
    func connectWebSocket()
}

public final class DefaultChatService: NSObject, ChatService, @unchecked Sendable {
    public var chatStream: PassthroughSubject<ChatDTO, Never> = .init()
    
    private let webSocket: WebSocket
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(webSocket: WebSocket) {
        self.webSocket = webSocket
        super.init()
    }
    
    func receive() {
        webSocket.dataStream.sinkHandledCompletion(receiveValue: { [weak self] data in
            guard let message = JSONManager.shared.decode(data: data, type: ServerMessage.self) else { return }
            switch message {
            case .newChat(let chatDTO):
                Log.log("WebSocket received new chat: \(chatDTO)")
                self?.chatStream.send(chatDTO)
            default:
                break
            }
        })
        .store(in: &cancellable)
    }
    
    public func send(messageDTO: MessageDTO) {
        Log.log("Sending chat message: \(messageDTO)")
        guard let messageData = JSONManager.shared.encode(codable: ClientMessage.sendChat(messageDTO)) else { return }
        webSocket.send(data: messageData)
    }
    
    public func connectWebSocket() {
        webSocket.connect()
        receive()
    }
}
