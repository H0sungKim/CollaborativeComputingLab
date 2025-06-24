//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Domain

import Foundation
import Combine

public final class SignalingService: @unchecked Sendable {
    private let webSocket: WebSocket
    
    var isConnected: CurrentValueSubject<Bool, Never> {
        return webSocket.isConnected
    }
    
//    var sdpSubject: PassthroughSubject<SessionDescription, Never> = .init()
//    var candidateSubject: PassthroughSubject<IceCandidate, Never> = .init()
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(webSocket: WebSocket) {
        self.webSocket = webSocket
        
        connect()
    }
    
    func connect() {
        webSocket.connect()
        receive()
        bindConnectionState()
    }
    
    func receive() {
//        webSocket.dataStream.sinkHandledCompletion(receiveValue: { [weak self] data in
//            guard let message = JSONManager.shared.decode(data: data, type: Message.self) else { return }
//            switch message {
//            case .sdp(let sessionDescription):
//                self?.sdpSubject.send(sessionDescription)
//            case .candidate(let iceCandidate):
//                self?.candidateSubject.send(iceCandidate)
//            }
//        })
//        .store(in: &cancellable)
    }
    
    func bindConnectionState() {
        isConnected
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] isConnected in
            NSLog("Signaling server connection state changed: \(isConnected)")
            if !isConnected {
                DispatchQueue.global().asyncAfter(deadline: .now() + 2) { [weak self] in
                    debugPrint("Trying to reconnect to signaling server...")
                    self?.webSocket.connect()
                }
            }
        })
        .store(in: &cancellable)
    }
    
//    
//    func sendSdp(_ sdp: SessionDescription) {
//        let message = Message.sdp(sdp)
//        guard let dataMessage = JSONManager.shared.encode(codable: message) else { return }
//        webSocket.send(data: dataMessage)
//    }
//    
//    func sendCandidate(_ iceCandidate: IceCandidate) {
//        let message = Message.candidate(iceCandidate)
//        guard let dataMessage = JSONManager.shared.encode(codable: message) else { return }
//        webSocket.send(data: dataMessage)
//    }
}
