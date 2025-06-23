//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.06.23.
//

import Domain

import WebRTC
import Foundation
import Combine

public final class DefaultWebRTCRepository: WebRTCRepository {
    
    private let webRTCService: WebRTCService
    
    public var localCandidateSubject: AnyPublisher<IceCandidate, Never> {
        return webRTCService.localCandidateSubject
            .map(\.iceCandidate)
            .eraseToAnyPublisher()
    }
    
    public init(webRTCService: WebRTCService) {
        self.webRTCService = webRTCService
    }
    
    public func offer() -> AnyPublisher<SessionDescription, WebRTCError> {
        return webRTCService.offer()
            .map(\.sessionDescription)
            .eraseToAnyPublisher()
    }
    
    public func answer() -> AnyPublisher<SessionDescription, WebRTCError> {
        return webRTCService.answer()
            .map(\.sessionDescription)
            .eraseToAnyPublisher()
    }
    
    public func setRemoteSdp(_ remoteSdp: SessionDescription) {
        webRTCService.setRemoteSdp(RTCSessionDescription(sessionDescription: remoteSdp))
    }
    
    public func setRemoteCandidate(_ remoteCandidate: IceCandidate) {
        webRTCService.setRemoteCandidate(RTCIceCandidate(iceCandidate: remoteCandidate))
    }
}
