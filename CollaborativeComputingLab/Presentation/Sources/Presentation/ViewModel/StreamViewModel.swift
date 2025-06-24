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
    func configure(roomRole: RoomRole, outputView: UIView) async
    
    func publish(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async
    func stopPublish() async
    
    func play() async
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
    
    public func configure(roomRole: RoomRole, outputView: UIView) async {
        await streamUseCase.configure(
            streamMode: roomRole.streamMode,
            outputView: outputView,
            audioEngine: AVAudioEngine(),
            screenRecorder: RPScreenRecorder.shared(),
            orientation: UIDevice.current.orientation,
            monitoringEnabled: DeviceUtil.isHeadphoneConnected()
        )
    }
    
    public func publish(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        do {
            try await streamUseCase.publish(video: video, audio: audio)
        } catch {
            print(error.localizedDescription)
        }
        startPublishScreen()
        observeNotification()
    }
    
    public func stopPublish() async {
        await streamUseCase.stopPublish()
        stopPublishScreen()
        removeNotification()
    }
    
    public func play() async {
        do {
            try await streamUseCase.play()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    public func stopPlay() async {
        await streamUseCase.stopPlay()
    }
    
    public func setScreenSize() async {
        await streamUseCase.setScreenSize(orientation: UIDevice.current.orientation)
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
                        await self?.streamUseCase.appendBuffer(sampleBuffer)
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
        }
    }
}
