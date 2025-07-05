//
//  WebSocket.swift
//  Data
//
//  Created by 김호성 on 2025.05.08.
//

import Domain

import Foundation
import Combine

public final class WebSocket: NSObject, @unchecked Sendable {
    
    private let url: URL
    private var socket: URLSessionWebSocketTask?
    private var timer: Timer?
    private var usage: Int = 0
    private lazy var urlSession: URLSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    
    var dataStream: PassthroughSubject<Data, WebSocketError> = .init()
    var isConnected: CurrentValueSubject<Bool, Never> = .init(false)
    
    public init(url: URL) {
        self.url = url
        super.init()
    }
    
    deinit {
        disconnect()
    }
    
    func startPing() {
        timer = Timer.scheduledTimer(withTimeInterval: 10, repeats: true, block: { [weak self] _ in
            self?.ping()
        })
    }
    
    private func ping() {
        socket?.sendPing(pongReceiveHandler: { error in
            if let error {
                Logger.log(error.localizedDescription, level: .error)
            }
        })
    }
    
    func connect() {
        if isConnected.value {
            return
        }
        Logger.log("WebSocket Connected.")
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
                Logger.log("WebSocket Receive Data: \(String(data: data, encoding: .utf8) ?? "")")
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
    
    private func disconnect() {
        Logger.log("WebSocket Disconnected.")
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
        Logger.log(closeCode)
        disconnect()
    }
}
