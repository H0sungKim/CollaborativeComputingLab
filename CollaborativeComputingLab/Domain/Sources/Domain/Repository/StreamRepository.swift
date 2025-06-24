//
//  StreamRepository.swift
//  Domain
//
//  Created by 김호성 on 2025.05.10.
//

import Foundation
import UIKit
import AVFoundation

public protocol StreamRepository: Sendable {
    func publish() async throws
    func play() async throws
    func close() async
    func addOutputView(_ view: UIView) async
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
    func setVideoOrientation(_ orientation: UIDeviceOrientation) async
    func setScreenSize(orientation: UIDeviceOrientation) async
    func configureVideoMixerSettings() async
    func configureScreen(orientation: UIDeviceOrientation) async
    func configureVideoScreenObject() async
    func configureAudio(audioEngine: sending AVAudioEngine) async
}
