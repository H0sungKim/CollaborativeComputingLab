//
//  StreamRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.05.10.
//

import AVFoundation

import HaishinKit

import Domain
import DTO
import Networking

public final class DefaultStreamRepository: StreamRepository {
    
    private let rtmpService: RTMPService
    private let streamService: StreamService
    
    public init(rtmpService: RTMPService, streamService: StreamService) {
        self.rtmpService = rtmpService
        self.streamService = streamService
    }
    
    public func publish(streamName: String) async {
        await rtmpService.publish(streamName: streamName)
    }
    
    public func play(streamName: String) async {
        await rtmpService.play(streamName: streamName)
    }
    
    public func close() async {
        await rtmpService.close()
    }
    
    public func addOutput(_ output: Any) async {
        if let output = output as? (any StreamOutput) {
            await rtmpService.addOutput(output)
        }
    }
    
    public func addOutputStream() async {
        await streamService.addOutputStream(stream: rtmpService.getStream())
    }
    
    public func appendBuffer(_ sampleBuffer: CMSampleBuffer) async {
        await streamService.appendBuffer(sampleBuffer)
    }
    
    public func attachAudioPlayer() async {
        await rtmpService.attachAudioPlayer(audioPlayer: streamService.getAudioPlayer())
    }
    
    public func attachMedia(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        await streamService.attachMedia(video: video, audio: audio)
    }
    
    public func detachMedia() async {
        await streamService.detachMedia()
    }
    
    public func startMixer() async {
        await streamService.startMixer()
    }
    
    public func stopMixer() async {
        await streamService.stopMixer()
    }
    
    public func setAudioCaptureDelegate() async {
        await streamService.setAudioCaptureDelegate()
    }
    
    public func removeAudioCaptureDelegate() async {
        await streamService.removeAudioCaptureDelegate()
    }
    
    public func setMonitoringEnabled(_ monitoringEnabled: Bool) async {
        await streamService.setMonitoringEnabled(monitoringEnabled)
    }
    
    public func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) async {
        await streamService.setVideoOrientation(orientation)
    }
    
    public func setScreenSize(orientation: AVCaptureVideoOrientation) async {
        await streamService.setScreenSize(orientation: orientation)
    }
    
    public func configureVideoMixerSettings() async {
        await streamService.configureVideoMixerSettings()
    }
    
    public func configureScreen(orientation: AVCaptureVideoOrientation) async {
        await streamService.configureScreen(orientation: orientation)
    }
    
    public func configureVideoScreenObject() async {
        await streamService.configureVideoScreenObject()
    }
    
    public func configureAudio(audioEngine: sending AVAudioEngine) async {
        await streamService.configureAudio(audioEngine: audioEngine)
    }
}
