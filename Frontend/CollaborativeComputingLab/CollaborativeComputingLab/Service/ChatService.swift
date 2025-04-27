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
    var webSocket: URLSessionWebSocketTask? { get }
    
    func send(message: String)
}

public final class DefaultChatService: NSObject, ChatService, @unchecked Sendable {
    
    public var webSocket: URLSessionWebSocketTask?
    private var timer: Timer?
    
    public override init() {
        super.init()
        
        let session: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        guard let url = URL(string: "ws://localhost:8080/websocket") else { return }
        
        webSocket = session.webSocketTask(with: url)
        webSocket?.resume()
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.ping()
        })
    }
    
    private func ping() {
        NSLog("PING")
        webSocket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        })
    }
    
    public func send(message: String) {
        print("Service SEND")
        webSocket?.send(URLSessionWebSocketTask.Message.string(message), completionHandler: { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        })
    }
    
    public func close() {
        webSocket?.cancel(with: .goingAway, reason: nil)
        timer?.invalidate()
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("OPEN ==")
    }

    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("CLOSE ==")
    }
}
