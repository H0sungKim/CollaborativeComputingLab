//
//  WebSocketService.swift
//  Data
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import Combine
import UIKit
import SwiftStomp

public protocol WebSocketService: URLSessionWebSocketDelegate {
    var chatStream: PassthroughSubject<ChatDTO, Error> { get }
    
    func send(chatDTO: ChatDTO)
    func connectWebSocket()
    func disconnectWebSocket()
}

public final class DefaultWebSocketService: NSObject, WebSocketService, @unchecked Sendable {
    
    private enum Destination: String {
        case chat = "/chat/chat"
        
        var sendTo: String {
            switch self {
            case .chat:
                return "/app/chat"
            }
        }
    }
    
    public var chatStream: PassthroughSubject<ChatDTO, any Error> = .init()
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var swiftStomp: SwiftStomp
    
    public init(uri: String) {
        self.swiftStomp = SwiftStomp(host: URL(string: "ws://\(uri):8080/ws")!)
        super.init()
        
        configure()
        bind()
    }
    
    private func configure() {
        self.swiftStomp.enableLogging = true
        self.swiftStomp.autoReconnect = true
        
        self.swiftStomp.enableAutoPing()
    }
    
    private func bind() {
        swiftStomp.eventsUpstream
            .sink { [weak self] event in
                guard let self else { return }
                
                switch event {
                case let .connected(type):
                    if type == .toStomp {
                        swiftStomp.subscribe(to: Destination.chat.rawValue)
                    }
                    break
                case .disconnected(_):
                    break
                case let .error(error):
                    print("Error: \(error)")
                }
            }
            .store(in: &cancellable)
        
        swiftStomp.messagesUpstream
            .sink { [weak self] message in
                guard let self else { return }
                switch message {
                case let .text(message, messageId, destination, _):
                    switch Destination(rawValue: destination) {
                    case .chat:
                        guard let dto = try? JSONManager.shared.decode(string: message, type: ChatDTO.self) else { return }
                        chatStream.send(dto)
                    case .none:
                        break
                    }
                    print(message)
                case let .data(data, messageId, destination, _):
                    print("data")
                    print(data)
                }
            }
            .store(in: &cancellable)
        
        swiftStomp.receiptUpstream
            .sink { receiptId in
                print("SwiftStop: Receipt received: \(receiptId)")
            }
            .store(in: &cancellable)
    }
    
    public func send(chatDTO: ChatDTO) {
        swiftStomp.send(body: chatDTO, to: Destination.chat.sendTo, headers: [:])
    }
    
    public func connectWebSocket() {
        if !swiftStomp.isConnected{
            swiftStomp.connect()
        }
    }
    
    public func disconnectWebSocket() {
        if swiftStomp.isConnected{
            swiftStomp.disconnect()
        }
    }
}
