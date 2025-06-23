//
//  StreamDIProvider.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.05.12.
//

import Domain
import Data
import Presentation

import Foundation

protocol StreamDIProvider {
    func makeSignalingService(webSocket: WebSocket?) -> SignalingService
    func makeWebRTCService(iceServers: [String]?) -> WebRTCService
    
    func makeSignalingRepository(signalingService: SignalingService?) -> SignalingRepository
    func makeWebRTCRepository(WebRTCService: WebRTCService?) -> WebRTCRepository
    
    func makeStreamUseCase(signalingRepository: SignalingRepository?, webRTCRepository: WebRTCRepository?) -> StreamUseCase
    
    func makeStreamViewModel(streamUseCase: StreamUseCase?) -> StreamViewModel
}

class DefaultStreamDIProvider: StreamDIProvider {
    func makeSignalingService(webSocket: WebSocket? = nil) -> SignalingService {
        return SignalingService(webSocket: webSocket ?? WebSocket(url: URL(string: "ws://\(Bundle.main.uri ?? ""):8080")!))
    }
    
    func makeWebRTCService(iceServers: [String]? = nil) -> WebRTCService {
        return WebRTCService(iceServers: iceServers ?? [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
            "stun:stun2.l.google.com:19302",
            "stun:stun3.l.google.com:19302",
            "stun:stun4.l.google.com:19302"
        ])
    }
    
    func makeSignalingRepository(signalingService: SignalingService? = nil) -> SignalingRepository {
        return DefaultSignalingRepository(signalingService: signalingService ?? makeSignalingService())
    }
    
    func makeWebRTCRepository(WebRTCService: WebRTCService? = nil) -> WebRTCRepository {
        return DefaultWebRTCRepository(webRTCService: WebRTCService ?? makeWebRTCService())
    }
    
    func makeStreamUseCase(signalingRepository: SignalingRepository? = nil, webRTCRepository: WebRTCRepository? = nil) -> StreamUseCase {
        return DefaultStreamUseCase(signalingRepository: signalingRepository ?? makeSignalingRepository(), webRTCRepository: webRTCRepository ?? makeWebRTCRepository())
    }
    
    func makeStreamViewModel(streamUseCase: StreamUseCase?) -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: streamUseCase ?? makeStreamUseCase())
    }
}
