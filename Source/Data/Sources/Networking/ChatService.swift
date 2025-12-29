//
//  ChatService.swift
//  Data
//
//  Created by 김호성 on 2025.06.25.
//

import Combine
import Foundation

import Core
import Domain
import DTO

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
            guard case let .newChat(chatDTO) = data.decode(type: ServerMessage.self) else { return }
            Log.i("WebSocket received new chat: \(chatDTO)")
            self?.chatStream.send(chatDTO)
        })
        .store(in: &cancellable)
    }
    
    public func send(messageDTO: MessageDTO) {
        guard let messageData = ClientMessage.sendChat(messageDTO).encode() else { return }
        webSocket.send(data: messageData)
        Log.i("Send chat message: \(messageDTO)")
    }
    
    public func connectWebSocket() {
        webSocket.connect()
        receive()
    }
}
