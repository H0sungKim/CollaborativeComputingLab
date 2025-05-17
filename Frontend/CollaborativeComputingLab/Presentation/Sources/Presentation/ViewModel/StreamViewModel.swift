//
//  StreamViewModel.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.11.
//

import Domain

import UIKit
import Foundation
import AVFoundation
import ReplayKit

import HaishinKit

public protocol StreamViewModelInput {
    func open(method: RoomRole) async
    func close() async
    
    func configure() async
    
    func startPublish() async
    func stopPublish() async
    
    func setScreenSize() async
    
    func addOutputView(_ view: UIView) async
    func attachAudioPlayer() async
    func appendAudio(buffer: AVAudioBuffer, time: AVAudioTime) async
    func configureAudioCaptureDelegate(delegate: AudioCaptureDelegate)
}

public protocol StreamViewModelOutput {
    
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput, Sendable { }

public final class DefaultStreamViewModel: StreamViewModel {
    
    private let streamUseCase: StreamUseCase
    
    private let mixer: MediaMixer = MediaMixer(multiCamSessionEnabled: true, multiTrackAudioMixingEnabled: true, useManualCapture: true)
    private let audioCapture: AudioCapture = AudioCapture()
    @ScreenActor private let videoScreenObject = VideoTrackScreenObject()
    private let audioPlayer = AudioPlayer(audioEngine: AVAudioEngine())
    
    @ScreenActor public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func open(method: RoomRole) async {
        await streamUseCase.open(method: method.streamRole)
    }
    
    public func close() async {
        await streamUseCase.close()
    }
    
    public func configure() async {
        await configureMixer()
        await configureScreen()
    }
    
    public func startPublish() async {
        await mixer.startRunning()
        await attachMedia()
        startPublishScreen()
        observeNotification()
    }
    
    public func stopPublish() async {
        await mixer.stopRunning()
        await detachMedia()
        stopPublishScreen()
        removeNotification()
    }
    
    @ScreenActor public func setScreenSize() async {
        if await UIDevice.current.orientation.isLandscape {
            mixer.screen.size = .init(width: 1280, height: 720)
        } else {
            mixer.screen.size = .init(width: 720, height: 1280)
        }
    }
    
    public func addOutputView(_ view: UIView) async {
        await streamUseCase.addOutputView(view)
    }
    
    public func attachAudioPlayer() async {
        await streamUseCase.attachAudioPlayer(audioPlayer: audioPlayer)
    }
    
    public func appendAudio(buffer: AVAudioBuffer, time: AVAudioTime) async {
        await mixer.append(buffer, when: time)
    }
    
    public func configureAudioCaptureDelegate(delegate: AudioCaptureDelegate) {
        audioCapture.delegate = delegate
    }
    
    private func attachMedia() async {
        try? await mixer.attachAudio(AVCaptureDevice.default(for: .audio))
        let front = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        try? await mixer.attachVideo(front, track: 1) { videoUnit in
            videoUnit.isVideoMirrored = true
        }
    }
    
    private func detachMedia() async {
        try? await mixer.attachAudio(nil)
        try? await mixer.attachVideo(nil, track: 0)
        try? await mixer.attachVideo(nil, track: 1)
    }
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    private func startPublishScreen() {
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
    
    private func stopPublishScreen() {
        DispatchQueue.global().async {
            RPScreenRecorder.shared().stopCapture(handler: { error in
                
            })
        }
    }
    
    private func configureMixer() async {
        if let orientation = await DeviceUtil.videoOrientation(by: UIApplication.shared.statusBarOrientation) {
            await mixer.setVideoOrientation(orientation)
        }
        await mixer.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
        await configureVideoMixerSettings()
        await addOutputStreamToMixer()
    }
    
    @ScreenActor private func configureScreen() async {
        await configureVideoScreenObject()
        await setScreenSize()
        mixer.screen.backgroundColor = UIColor.clear.cgColor
        try? mixer.screen.addChild(videoScreenObject)
    }
    
    private func addOutputStreamToMixer() async {
        await streamUseCase.addOutputStreamToMixer(mixer: mixer)
    }
    
    @ScreenActor private func configureVideoScreenObject() async {
        videoScreenObject.cornerRadius = 16.0
        videoScreenObject.track = 1
        videoScreenObject.horizontalAlignment = .right
        videoScreenObject.layoutMargin = .init(top: 16, left: 0, bottom: 0, right: 16)
        videoScreenObject.size = .init(width: 160 * 2, height: 90 * 2)
    }
    
    private func configureVideoMixerSettings() async {
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
