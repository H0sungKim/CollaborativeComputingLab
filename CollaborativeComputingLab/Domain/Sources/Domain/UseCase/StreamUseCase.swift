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
    var signalingConnection: CurrentValueSubject<Bool, Never> { get }
    var hasLocalSdp: CurrentValueSubject<Bool, Never> { get }
    var hasRemoteSdp: CurrentValueSubject<Bool, Never> { get }
    var webRTCConnection: CurrentValueSubject<IceConnectionState, Never> { get }
    
    func offer()
    func answer()
    func startCaptureLocalVideo(view: UIView)
}

public final class DefaultStreamUseCase: StreamUseCase {
    
    private let signalingRepository: SignalingRepository
    private let webRTCRepository: WebRTCRepository
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public var signalingConnection: CurrentValueSubject<Bool, Never> {
        return signalingRepository.isConnected
    }
    
    public var hasLocalSdp: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var hasRemoteSdp: CurrentValueSubject<Bool, Never> = .init(false)
    
    public var webRTCConnection: CurrentValueSubject<IceConnectionState, Never> {
        return webRTCRepository.connectionState
    }
    
    public init(signalingRepository: SignalingRepository, webRTCRepository: WebRTCRepository) {
        self.signalingRepository = signalingRepository
        self.webRTCRepository = webRTCRepository
        
        bind()
    }
    
    public func offer() {
        webRTCRepository.offer().sinkHandledCompletion(receiveValue: { [weak self] sdp in
            NSLog("Offer SDP: \(sdp)")
            self?.signalingRepository.sendSdp(sdp)
            self?.hasLocalSdp.send(true)
        })
        .store(in: &cancellable)
    }
    
    public func answer() {
        webRTCRepository.answer().sinkHandledCompletion(receiveValue: { [weak self] sdp in
            NSLog("Answer SDP: \(sdp)")
            self?.signalingRepository.sendSdp(sdp)
            self?.hasLocalSdp.send(true)
        })
        .store(in: &cancellable)
    }
    
    public func startCaptureLocalVideo(view: UIView) {
        webRTCRepository.startCaptureLocalVideo(view: view)
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
            self?.hasRemoteSdp.send(true)
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
