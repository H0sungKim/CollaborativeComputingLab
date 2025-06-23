//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Domain

import Foundation
import Combine
@preconcurrency import WebRTC

public final class WebRTCService: NSObject, @unchecked Sendable {
    
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
    private static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    var connectionState: CurrentValueSubject<IceConnectionState, Never> = .init(.closed)
    var localCandidateSubject: PassthroughSubject<RTCIceCandidate, Never> = .init()
    
    private let peerConnection: RTCPeerConnection
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]    
    private var videoCapturer: RTCVideoCapturer?
    private var localVideoTrack: RTCVideoTrack?
    private var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    private var remoteDataChannel: RTCDataChannel?

    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    public required init(iceServers: [String]) {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        
        // Unified plan is more superior than planB
        config.sdpSemantics = .unifiedPlan
        
        // gatherContinually will let WebRTC to listen to any network changes and send any new candidates to the other client
        config.continualGatheringPolicy = .gatherContinually
        
        // Define media constraints. DtlsSrtpKeyAgreement is required to be true to be able to connect with web browsers.
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil,
                                              optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        
        guard let peerConnection = WebRTCService.factory.peerConnection(with: config, constraints: constraints, delegate: nil) else {
            fatalError("Could not create new RTCPeerConnection")
        }
        
        self.peerConnection = peerConnection
        
        super.init()
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection.delegate = self
    }
    
    // MARK: Signaling
    func offer() -> AnyPublisher<RTCSessionDescription, WebRTCError> {
        return Future<RTCSessionDescription, WebRTCError> { [weak self] promise in
            guard let self else { return }
            let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
            peerConnection.offer(for: constrains) { (sdp, error) in
                guard let sdp else {
                    promise(.failure(.offerSdpFailed(error: error)))
                    return
                }
                if let error {
                    promise(.failure(.offerSdpFailed(error: error)))
                }
                self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                    if let error {
                        promise(.failure(.setLocalSdpFailed(error: error)))
                    }
                    promise(.success(sdp))
                })
            }
        }
        .eraseToAnyPublisher()
    }
    
    func answer() -> AnyPublisher<RTCSessionDescription, WebRTCError> {
        return Future<RTCSessionDescription, WebRTCError> { [weak self] promise in
            guard let self else { return }
            let constrains = RTCMediaConstraints(mandatoryConstraints: mediaConstrains, optionalConstraints: nil)
            peerConnection.answer(for: constrains) { (sdp, error) in
                guard let sdp else {
                    promise(.failure(.answerSdpFailed(error: error)))
                    return
                }
                if let error {
                    promise(.failure(.answerSdpFailed(error: error)))
                }
                self.peerConnection.setLocalDescription(sdp, completionHandler: { (error) in
                    if let error {
                        promise(.failure(.setLocalSdpFailed(error: error)))
                    }
                    promise(.success(sdp))
                })
            }
        }
        .eraseToAnyPublisher()
    }
    
    
    
    func setRemoteSdp(_ remoteSdp: RTCSessionDescription) {
        peerConnection.setRemoteDescription(remoteSdp, completionHandler: { error in
            guard let error else { return }
            NSLog(WebRTCError.setRemoteSdpFailed(error: error).localizedDescription)
        })
    }
    
    func setRemoteCandidate(_ remoteCandidate: RTCIceCandidate) {
        peerConnection.add(remoteCandidate, completionHandler: { error in
            guard let error else { return }
            NSLog(WebRTCError.addRemoteCandidateFailed(error: error).localizedDescription)
        })
    }
    
    // MARK: Media
    func startCaptureLocalVideo(renderer: RTCVideoRenderer) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }

        guard
            let frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front }),
        
            // choose highest res
            let format = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera).sorted { (f1, f2) -> Bool in
                let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
                let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
                return width1 < width2
            }).last,
        
            // choose highest fps
            let fps = (format.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last) else {
            return
        }
        
        capturer.startCapture(with: frontCamera,
                              format: format,
                              fps: Int(fps.maxFrameRate))
        
        self.localVideoTrack?.add(renderer)
    }
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }
    
    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        self.peerConnection.add(audioTrack, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        self.peerConnection.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // Data
        if let dataChannel = createDataChannel() {
            dataChannel.delegate = self
            self.localDataChannel = dataChannel
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCService.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCService.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    private func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCService.factory.videoSource()
        
        #if targetEnvironment(simulator)
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCService.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        guard let dataChannel = self.peerConnection.dataChannel(forLabel: "WebRTCData", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
        self.remoteDataChannel?.sendData(buffer)
    }
}

extension WebRTCService: RTCPeerConnectionDelegate {
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        debugPrint("peerConnection did add stream")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        debugPrint("peerConnection did remove stream")
    }
    
    public func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        connectionState.send(newState.iceConnectionState)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        localCandidateSubject.send(candidate)
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    public func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open data channel")
        self.remoteDataChannel = dataChannel
    }
}
extension WebRTCService {
    private func setTrackEnabled<T: RTCMediaStreamTrack>(_ type: T.Type, isEnabled: Bool) {
        peerConnection.transceivers
            .compactMap { return $0.sender.track as? T }
            .forEach { $0.isEnabled = isEnabled }
    }
}

// MARK: - Video control
extension WebRTCService {
    func hideVideo() {
        self.setVideoEnabled(false)
    }
    func showVideo() {
        self.setVideoEnabled(true)
    }
    private func setVideoEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCVideoTrack.self, isEnabled: isEnabled)
    }
}
// MARK: - Audio control
extension WebRTCService {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    // Fallback to the default playing device: headphones/bluetooth/ear speaker
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    // Force speaker
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        setTrackEnabled(RTCAudioTrack.self, isEnabled: isEnabled)
    }
}

extension WebRTCService: RTCDataChannelDelegate {
    public func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        debugPrint("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    public func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
//        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
}
