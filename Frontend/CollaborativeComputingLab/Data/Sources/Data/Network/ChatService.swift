//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import Combine
import UIKit
import SwiftStomp

public protocol ChatService: URLSessionWebSocketDelegate {
    var chatStream: PassthroughSubject<ChatDTO, Error> { get }
    
    func send(chatDTO: ChatDTO)
    func connectWebSocket()
    func disconnectWebSocket()
}

public final class DefaultChatService: NSObject, ChatService, @unchecked Sendable {
    
    public var chatStream: PassthroughSubject<ChatDTO, any Error> = .init()
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    private var swiftStomp = SwiftStomp(host: URL(string: "\(Bundle.module.baseURL ?? "")/ws")!)
    
    public override init() {
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
                        swiftStomp.subscribe(to: "/chat/chat")
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
                    guard let dto = try? JSONManager.shared.decode(string: message, type: ChatDTO.self) else { return }
                    chatStream.send(dto)
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
        swiftStomp.send(body: chatDTO, to: "/app/chat", headers: [:])
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
