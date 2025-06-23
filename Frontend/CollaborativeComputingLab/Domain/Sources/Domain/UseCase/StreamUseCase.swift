//
//  StreamUseCase.swift
//  Domain
//
//  Created by 김호성 on 2025.05.12.
//

import Foundation
import AVFoundation
import UIKit
import ReplayKit
import Combine

public protocol StreamUseCase {
    func offer()
    func answer()
}

public final class DefaultStreamUseCase: StreamUseCase {
    
    private let signalingRepository: SignalingRepository
    private let webRTCRepository: WebRTCRepository
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(signalingRepository: SignalingRepository, webRTCRepository: WebRTCRepository) {
        self.signalingRepository = signalingRepository
        self.webRTCRepository = webRTCRepository
        
        bind()
    }
    
    public func offer() {
        webRTCRepository.offer().sinkHandledCompletion(receiveValue: { [weak self] sdp in
            NSLog("Offer SDP: \(sdp)")
            self?.signalingRepository.sendSdp(sdp)
        })
        .store(in: &cancellable)
    }
    
    public func answer() {
        webRTCRepository.answer().sinkHandledCompletion(receiveValue: { [weak self] sdp in
            NSLog("Answer SDP: \(sdp)")
            self?.signalingRepository.sendSdp(sdp)
        })
        .store(in: &cancellable)
    }
    
    private func bind() {
        bindLocalCandidate()
        bindRemoteSdp()
        bindRemoteCandidate()
    }
    
    private func bindLocalCandidate() {
        webRTCRepository.localCandidateSubject.sink(receiveValue: { [weak self] candidate in
            NSLog("Local Candidate: \(candidate)")
            self?.signalingRepository.sendCandidate(candidate)
        })
        .store(in: &cancellable)
    }
    
    private func bindRemoteSdp() {
        signalingRepository.sdpSubject.sink(receiveValue: { [weak self] sdp in
            NSLog("Remote SDP: \(sdp)")
            self?.webRTCRepository.setRemoteSdp(sdp)
        })
        .store(in: &cancellable)
    }
    
    private func bindRemoteCandidate() {
        signalingRepository.candidateSubject.sink(receiveValue: { [weak self] candidate in
            NSLog("Remote Candidate: \(candidate)")
            self?.webRTCRepository.setRemoteCandidate(candidate)
        })
        .store(in: &cancellable)
    }
}
