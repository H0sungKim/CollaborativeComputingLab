//
//  NativeSocketProvider.swift
//  WebRTC-Demo
//
//  Created by stasel on 15/07/2019.
//  Copyright © 2019 stasel. All rights reserved.
//

import Domain

import Foundation
import Combine

public final class WebSocket: NSObject, @unchecked Sendable {
    
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private var timer: Timer?
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    var dataStream: PassthroughSubject<Data, WebSocketError> = .init()
    var isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    func startPing() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.ping()
        })
    }
    
    private func ping() {
        socket?.sendPing(pongReceiveHandler: { error in
            if let error = error {
                NSLog(error.localizedDescription)
            }
        })
    }
    
    func connect() {
        let socket = urlSession.webSocketTask(with: url)
        socket.resume()
        self.socket = socket
        startPing()
        receive()
    }
    
    func send(data: Data) {
        socket?.send(.data(data)) { _ in }
    }
    
    private func receive() {
        socket?.receive(completionHandler: { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(.data(let data)):
                dataStream.send(data)
            case .success(.string(let string)):
                dataStream.send(completion: .failure(.nonDataMessage(message: string)))
            case .success:
                dataStream.send(completion: .failure(.unknownTypeMessage))
            case .failure(let error):
                dataStream.send(completion: .failure(.messageReceiveFailed(error: error)))
                disconnect()
            }
            receive()
        })
    }
    
    func disconnect() {
        socket?.cancel()
        socket = nil
        timer?.invalidate()
        isConnected.send(false)
    }
}

extension WebSocket: URLSessionWebSocketDelegate, URLSessionDelegate  {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        isConnected.send(true)
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        disconnect()
    }
}
