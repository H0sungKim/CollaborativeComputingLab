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
    
    public var connectionState: CurrentValueSubject<IceConnectionState, Never> {
        return webRTCService.connectionState
    }
    
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
    
    public func startCaptureLocalVideo(view: UIView) {
        guard let renderer = view as? RTCVideoRenderer else { return }
        webRTCService.startCaptureLocalVideo(renderer: renderer)
    }
}
