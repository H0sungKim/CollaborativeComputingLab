//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.11.
//

import Domain

import HaishinKit
import UIKit
import Foundation
import AVFoundation
import ReplayKit

public protocol StreamViewModelInput {
    func open(method: StreamRole) async
    func close(method: StreamRole) async
    func addOutputView(_ view: UIView) async
    func addOutputStreamToMixer() async
    func attachAudioPlayer(audioPlayer: AudioPlayer) async
    func attachMedia() async
    func detachMedia() async
    func observeNotification()
    func removeNotification()
    func startPublishScreen()
    func stopPublishScreen()
    func setScreenSize()
    func configureVideoScreenObject() async
    func setVideoMixerSettings() async
}

public protocol StreamViewModelOutput {
    var mixer: MediaMixer { get }
    
    var videoScreenObject: VideoTrackScreenObject { get }
    var audioPlayer: AudioPlayer { get }
    var audioCapture: AudioCapture { get }
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput, Sendable { }

public final class DefaultStreamViewModel: StreamViewModel {
    
    public let mixer: MediaMixer = MediaMixer(multiCamSessionEnabled: true, multiTrackAudioMixingEnabled: true, useManualCapture: true)
    @ScreenActor public let videoScreenObject = VideoTrackScreenObject()
    public let audioPlayer = AudioPlayer(audioEngine: AVAudioEngine())
    public let audioCapture: AudioCapture = AudioCapture()
    
    private let streamUseCase: StreamUseCase
    
    @ScreenActor public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func open(method: StreamRole) async {
        await streamUseCase.open(method: method)
    }
    
    public func attachMedia() async {
        try? await mixer.attachAudio(AVCaptureDevice.default(for: .audio))
        let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        try? await mixer.attachVideo(front, track: 1) { videoUnit in
            videoUnit.isVideoMirrored = true
        }
    }
    
    public func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    public func close(method: StreamRole) async {
        await streamUseCase.close()
    }
    
    public func detachMedia() async {
        try? await mixer.attachAudio(nil)
        try? await mixer.attachVideo(nil, track: 0)
        try? await mixer.attachVideo(nil, track: 1)
    }
    
    public func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func addOutputView(_ view: UIView) async {
        await streamUseCase.addOutputView(view)
    }
    
    public func addOutputStreamToMixer() async {
        await streamUseCase.addOutputStreamToMixer(mixer: mixer)
    }
    
    public func attachAudioPlayer(audioPlayer: AudioPlayer) async {
        await streamUseCase.attachAudioPlayer(audioPlayer: audioPlayer)
    }
    
    public func startPublishScreen() {
        DispatchQueue.global().async {
            RPScreenRecorder.shared().startCapture(handler: { sampleBuffer, sampleBufferType, error in
                if error != nil {
                    print(error?.localizedDescription)
                    return
                }
                switch sampleBufferType {
                case .video:
                    Task { [weak self] in
                        await self?.mixer.append(sampleBuffer, track: 0)
                    }
                case .audioApp:
                    break
                case .audioMic:
                    break
                @unknown default:
                    break
                }
            }, completionHandler: { error in
                print(error?.localizedDescription)
            })
        }
    }
    
    public func stopPublishScreen() {
        DispatchQueue.global().async {
            RPScreenRecorder.shared().stopCapture(handler: { error in
                
            })
        }
    }
    
    public func setScreenSize() {
        Task { @ScreenActor in
            if await UIDevice.current.orientation.isLandscape {
                mixer.screen.size = .init(width: 1280, height: 720)
            } else {
                mixer.screen.size = .init(width: 720, height: 1280)
            }
        }
    }
    
    @ScreenActor public func configureVideoScreenObject() async {
        videoScreenObject.cornerRadius = 16.0
        videoScreenObject.track = 1
        videoScreenObject.horizontalAlignment = .right
        videoScreenObject.layoutMargin = .init(top: 16, left: 0, bottom: 0, right: 16)
        videoScreenObject.size = .init(width: 160 * 2, height: 90 * 2)
    }
    
    public func setVideoMixerSettings() async {
        var videoMixerSettings = await mixer.videoMixerSettings
        videoMixerSettings.mode = .offscreen
        await mixer.setVideoMixerSettings(videoMixerSettings)
    }
    
    @MainActor @objc private func didRouteChangeNotification(_ notification: Notification) {
        if AVAudioSession.sharedInstance().inputDataSources?.isEmpty == true {
            setEnabledPreferredInputBuiltInMic(false)
        } else {
            setEnabledPreferredInputBuiltInMic(true)
        }
        Task {
            if DeviceUtil.isHeadphoneDisconnected(notification) {
                await mixer.setMonitoringEnabled(false)
            } else {
                await mixer.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
            }
        }
    }
    
    @MainActor @objc private func orientationDidChange(_ notification: Notification) {
        guard let orientation = DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) else {
            return
        }
        Task {
            await mixer.setVideoOrientation(orientation)
        }
    }
    
    private func setEnabledPreferredInputBuiltInMic(_ isEnabled: Bool) {
        let session = AVAudioSession.sharedInstance()
        do {
            if isEnabled {
                guard
                    let availableInputs = session.availableInputs,
                    let builtInMicInput = availableInputs.first(where: { $0.portType == .builtInMic }) else {
                    return
                }
                try session.setPreferredInput(builtInMicInput)
            } else {
                try session.setPreferredInput(nil)
            }
        } catch {
        }
    }
}
