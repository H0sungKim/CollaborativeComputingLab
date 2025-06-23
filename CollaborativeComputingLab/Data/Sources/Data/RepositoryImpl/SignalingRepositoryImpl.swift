//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.06.23.
//

import Domain

import Foundation
import WebRTC
import Combine

public final class DefaultSignalingRepository: SignalingRepository {
    
    private let signalingService: SignalingService
    
    public var isConnected: CurrentValueSubject<Bool, Never> {
        return signalingService.isConnected
    }
    
    public var sdpSubject: AnyPublisher<SessionDescription, Never> {
        return signalingService.sdpSubject.eraseToAnyPublisher()
    }
    
    public var candidateSubject: AnyPublisher<IceCandidate, Never> {
        return signalingService.candidateSubject.eraseToAnyPublisher()
    }
    
    public init(signalingService: SignalingService) {
        self.signalingService = signalingService
    }
    
    public func sendSdp(_ sdp: SessionDescription) {
        signalingService.sendSdp(sdp)
    }
    
    public func sendCandidate(_ iceCandidate: IceCandidate) {
        signalingService.sendCandidate(iceCandidate)
    }
}
