//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.06.25.
//

import Foundation
import Combine

public protocol ChatService: URLSessionWebSocketDelegate {
    var chatStream: PassthroughSubject<ChatDTO, Never> { get }
    
    func send(chatDTO: ChatDTO)
    func connectWebSocket()
    func disconnectWebSocket()
}

public final class DefaultChatService: NSObject, ChatService, @unchecked Sendable {
    public var chatStream: PassthroughSubject<ChatDTO, Never> = .init()
    
    private let webSocket: WebSocket
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(webSocket: WebSocket) {
        self.webSocket = webSocket
        super.init()
    }
    
    public func connectWebSocket() {
        webSocket.connect()
        receive()
    }
    
    func receive() {
        webSocket.dataStream.sinkHandledCompletion(receiveValue: { [weak self] data in
            guard let message = JSONManager.shared.decode(data: data, type: ChatDTO.self) else { return }
            self?.chatStream.send(message)
        })
        .store(in: &cancellable)
    }
    
    public func send(chatDTO: ChatDTO) {
        guard let dataMessage = JSONManager.shared.encode(codable: chatDTO) else { return }
        webSocket.send(data: dataMessage)
    }
    
    public func disconnectWebSocket() {
        webSocket.disconnect()
    }
}
