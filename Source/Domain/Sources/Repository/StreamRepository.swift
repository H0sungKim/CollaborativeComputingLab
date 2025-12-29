//
//  StreamRepository.swift
//  Domain
//
//  Created by 김호성 on 2025.05.10.
//

import AVFoundation
import Foundation

public protocol StreamRepository: Sendable {
    func publish(streamName: String) async
    func play(streamName: String) async
    func close() async
    func addOutput(_ output: Any) async
    func addOutputStream() async
    func appendBuffer(_ sampleBuffer: CMSampleBuffer) async
    func attachAudioPlayer() async
    func attachMedia(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async
    func detachMedia() async
    func startMixer() async
    func stopMixer() async
    func setAudioCaptureDelegate() async
    func removeAudioCaptureDelegate() async
    func setMonitoringEnabled(_ monitoringEnabled: Bool) async
    func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) async
    func setScreenSize(orientation: AVCaptureVideoOrientation) async
    func configureVideoMixerSettings() async
    func configureScreen(orientation: AVCaptureVideoOrientation) async
    func configureVideoScreenObject() async
    func configureAudio(audioEngine: sending AVAudioEngine) async
}
