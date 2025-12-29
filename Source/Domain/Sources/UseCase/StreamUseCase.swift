//
//  StreamUseCase.swift
//  Domain
//
//  Created by 김호성 on 2025.05.12.
//

import Repository

import AVFoundation
import Foundation
import ReplayKit

public protocol StreamUseCase: Sendable {
    func configure(streamMode: StreamMode, output: Any?, audioEngine: sending AVAudioEngine, screenRecorder: sending RPScreenRecorder, orientation: AVCaptureVideoOrientation, monitoringEnabled: Bool) async
    
    func publish(streamName: String, video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async
    func stopPublish() async
    
    func play(streamName: String) async
    func stopPlay() async
    
    func setMonitoringEnabled(_ monitoringEnabled: Bool) async
    func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) async
    func setScreenSize(orientation: AVCaptureVideoOrientation) async
    func appendBuffer(_ sampleBuffer: CMSampleBuffer) async
}

public final class DefaultStreamUseCase: StreamUseCase {
    
    private let streamRepository: StreamRepository
    
    public init(streamRepository: StreamRepository) {
        self.streamRepository = streamRepository
    }
    
    public func configure(streamMode: StreamMode, output: Any?, audioEngine: sending AVAudioEngine, screenRecorder: sending RPScreenRecorder, orientation: AVCaptureVideoOrientation, monitoringEnabled: Bool) async {
        if let output {
            await streamRepository.addOutput(output)
        }
        await streamRepository.configureAudio(audioEngine: audioEngine)
        switch streamMode {
        case .publish:
            await streamRepository.setAudioCaptureDelegate()
            await streamRepository.setVideoOrientation(orientation)
            await streamRepository.setMonitoringEnabled(monitoringEnabled)
            await streamRepository.configureVideoMixerSettings()
            await streamRepository.addOutputStream()
            
            await streamRepository.configureVideoScreenObject()
            await streamRepository.configureScreen(orientation: orientation)
        case .play:
            await streamRepository.attachAudioPlayer()
        }
    }
    
    public func publish(streamName: String, video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        await streamRepository.publish(streamName: streamName)
        await streamRepository.startMixer()
        await streamRepository.attachMedia(video: video, audio: audio)
    }
    
    public func stopPublish() async {
        await streamRepository.close()
        await streamRepository.stopMixer()
        await streamRepository.detachMedia()
    }
    
    public func play(streamName: String) async {
        await streamRepository.play(streamName: streamName)
    }
    
    
    public func stopPlay() async {
        await streamRepository.close()
    }
    
    public func setMonitoringEnabled(_ monitoringEnabled: Bool) async {
        await streamRepository.setMonitoringEnabled(monitoringEnabled)
    }
    
    public func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) async {
        await streamRepository.setVideoOrientation(orientation)
    }
    
    public func setScreenSize(orientation: AVCaptureVideoOrientation) async {
        await streamRepository.setScreenSize(orientation: orientation)
    }
    
    public func appendBuffer(_ sampleBuffer: CMSampleBuffer) async {
        await streamRepository.appendBuffer(sampleBuffer)
    }
}
