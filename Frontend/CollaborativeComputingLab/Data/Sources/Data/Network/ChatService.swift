//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import Combine
import UIKit

public protocol ChatService: URLSessionWebSocketDelegate {
    var chatStream: PassthroughSubject<ChatDTO, Error> { get }
    
    func send(message: String)
}

public final class DefaultChatService: NSObject, ChatService, @unchecked Sendable {
    
    private var webSocket: URLSessionWebSocketTask?
    private var timer: Timer?
    
    public var chatStream: PassthroughSubject<ChatDTO, Error> = .init()
    
    public override init() {
        super.init()
        
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "ws://localhost:8080/websocket/chat") else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.ping()
        })
        receive()
    }
    
    private func ping() {
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                NSLog("Chat Service Ping Error - \(error.localizedDescription)")
            }
        })
    }
    
    private func receive() {
        webSocket?.receive(completionHandler: { [weak self] result in
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    break
                case .string(let string):
                    do {
                        let dto = try JSONManager.shared.decode(string: string, type: ChatDTO.self)
                        self?.chatStream.send(dto)
                    } catch {
                        self?.chatStream.send(completion: .failure(error))
                    }
                @unknown default:
                    break
                }
            case .failure(let error):
                self?.chatStream.send(completion: .failure(error))
            }
            self?.receive()
        })
    }
    
    public func send(message: String) {
        webSocket?.send(URLSessionWebSocketTask.Message.string(message), completionHandler: { error in
            if let error = error {
                NSLog("Chat Service Send Error - \(error.localizedDescription)")
            }
        })
    }
    
    public func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        timer?.invalidate()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("OPEN")
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("CLOSE")
    }
}
