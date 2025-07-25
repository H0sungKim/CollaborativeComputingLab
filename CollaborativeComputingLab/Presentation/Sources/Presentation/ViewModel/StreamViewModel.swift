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
    func configure(roomRole: RoomRole, outputView: UIView?) async
    
    func publish(streamName: String, view: UIView, video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async
    func stopPublish() async
    
    func play(streamName: String) async
    func stopPlay() async
    
    func setScreenSize() async
}

public protocol StreamViewModelOutput {
    
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput, Sendable { }

public final class DefaultStreamViewModel: StreamViewModel {
    
    private let streamUseCase: StreamUseCase
    
    public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func configure(roomRole: RoomRole, outputView: UIView?) async {
        await streamUseCase.configure(
            streamMode: roomRole.streamMode,
            outputView: outputView,
            audioEngine: AVAudioEngine(),
            screenRecorder: RPScreenRecorder.shared(),
            orientation: UIDevice.current.orientation,
            monitoringEnabled: DeviceUtil.isHeadphoneConnected()
        )
    }
    
    public func publish(streamName: String, view: UIView, video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        await streamUseCase.publish(streamName: streamName, video: video, audio: audio)
        startPublishScreen(view: view)
        observeNotification()
    }
    
    public func stopPublish() async {
        await streamUseCase.stopPublish()
        stopPublishScreen()
        removeNotification()
    }
    
    public func play(streamName: String) async {
        await streamUseCase.play(streamName: streamName)
    }
    
    public func stopPlay() async {
        await streamUseCase.stopPlay()
    }
    
    public func setScreenSize() async {
        await streamUseCase.setScreenSize(orientation: UIDevice.current.orientation)
    }
    
    
    private func startPublishScreen(view: UIView) {
        DispatchQueue.global().async {
            RPScreenRecorder.shared().startCapture(handler: { sampleBuffer, sampleBufferType, error in
                if let error {
                    Log.log(error.localizedDescription, level: .error)
                    return
                }
                switch sampleBufferType {
                case .video:
                    Task { [weak self] in
                        guard let resizedSampleBuffer = await sampleBuffer.resize(to: view) else { return }
                        await self?.streamUseCase.appendBuffer(resizedSampleBuffer)
                    }
                case .audioApp:
                    break
                case .audioMic:
                    break
                @unknown default:
                    break
                }
            }, completionHandler: { error in
                guard let error else { return }
                Log.log(error.localizedDescription, level: .error)
            })
        }
    }
    
    private func stopPublishScreen() {
        DispatchQueue.global().async {
            RPScreenRecorder.shared().stopCapture(handler: { error in
                guard let error else { return }
                Log.log(error.localizedDescription, level: .error)
            })
        }
    }
    
    private func observeNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didRouteChangeNotification(_:)), name: AVAudioSession.routeChangeNotification, object: nil)
    }
    
    private func removeNotification() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @MainActor @objc private func didRouteChangeNotification(_ notification: Notification) {
        if AVAudioSession.sharedInstance().inputDataSources?.isEmpty == true {
            setEnabledPreferredInputBuiltInMic(false)
        } else {
            setEnabledPreferredInputBuiltInMic(true)
        }
        Task {
            if DeviceUtil.isHeadphoneDisconnected(notification) {
                await streamUseCase.setMonitoringEnabled(false)
            } else {
                await streamUseCase.setMonitoringEnabled(DeviceUtil.isHeadphoneConnected())
            }
        }
    }
    
    @MainActor @objc private func orientationDidChange(_ notification: Notification) {
        Task {
            await streamUseCase.setVideoOrientation(UIDevice.current.orientation)
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
            Log.log(error.localizedDescription, level: .error)
        }
    }
}
