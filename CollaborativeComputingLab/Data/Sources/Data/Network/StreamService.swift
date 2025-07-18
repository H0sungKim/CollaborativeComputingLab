//
//  StreamService.swift
//  Data
//
//  Created by 김호성 on 2025.05.18.
//

import Domain

import Foundation
import AVFoundation
import UIKit

import HaishinKit

public final actor StreamService {
    private let mixer: MediaMixer = MediaMixer(multiCamSessionEnabled: true, multiTrackAudioMixingEnabled: true, useManualCapture: true)
    private var audioCapture: AudioCapture!
    @ScreenActor private lazy var videoScreenObject: VideoTrackScreenObject = VideoTrackScreenObject()
    private var audioPlayer: AudioPlayer!
    
    public init() {
        
    }
    
    func attachMedia(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        do {
            try await mixer.attachVideo(video, track: 1) { videoUnit in
                videoUnit.isVideoMirrored = true
            }
            try await mixer.attachAudio(audio)
        } catch {
            Log.log(error.localizedDescription, level: .error)
        }
    }
    
    func detachMedia() async {
        do {
            try await mixer.attachAudio(nil)
            try await mixer.attachVideo(nil, track: 0)
            try await mixer.attachVideo(nil, track: 1)
        } catch {
            Log.log(error.localizedDescription, level: .error)
        }
    }
    
    func startMixer() async {
        await mixer.startRunning()
    }
    
    func stopMixer() async {
        await mixer.stopRunning()
    }
    
    @ScreenActor func setScreenSize(orientation: UIDeviceOrientation) async {
        mixer.screen.size = orientation.isLandscape ? CGSize(width: 1280, height: 720) : CGSize(width: 720, height: 1280)
    }
    
    @ScreenActor func configureScreen(orientation: UIDeviceOrientation) async {
        await setScreenSize(orientation: orientation)
        mixer.screen.backgroundColor = UIColor.clear.cgColor
    }
    
    @ScreenActor func configureVideoScreenObject() async {
        videoScreenObject.cornerRadius = 16.0
        videoScreenObject.track = 1
        videoScreenObject.horizontalAlignment = .right
        videoScreenObject.layoutMargin = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)
        videoScreenObject.size = CGSize(width: 160 * 2, height: 90 * 2)
        do {
            try mixer.screen.addChild(videoScreenObject)
        } catch {
            Log.log(error.localizedDescription, level: .error)
        }
    }
    
    func configureAudio(audioEngine: AVAudioEngine) {
        Task {
            audioPlayer = AudioPlayer(audioEngine: audioEngine)
        }
        audioCapture = AudioCapture(audioEngine: audioEngine)
    }
    
    func configureVideoMixerSettings() async {
        var videoMixerSettings = await mixer.videoMixerSettings
        videoMixerSettings.mode = .offscreen
        await mixer.setVideoMixerSettings(videoMixerSettings)
    }
    
    func setAudioCaptureDelegate() {
        audioCapture.delegate = self
    }
    
    func removeAudioCaptureDelegate() {
        audioCapture.delegate = nil
    }
    
    func setMonitoringEnabled(_ monitoringEnabled: Bool) async {
        await mixer.setMonitoringEnabled(monitoringEnabled)
    }
    
    func setVideoOrientation(_ orientation: UIDeviceOrientation) async {
        if let videoOrientation = DeviceUtil.videoOrientation(by: orientation) {
            await mixer.setVideoOrientation(videoOrientation)
        }
    }
    
    func getAudioPlayer() -> AudioPlayer {
        return audioPlayer
    }
    
    func addOutputStream(stream: RTMPStream) async {
        await mixer.addOutput(stream)
    }
    
    func appendBuffer(_ sampleBuffer: CMSampleBuffer) async {
        await mixer.append(sampleBuffer, track: 0)
    }
}

extension StreamService: @preconcurrency AudioCaptureDelegate {
    public func audioCapture(_ audioCapture: AudioCapture, buffer: AVAudioBuffer, time: AVAudioTime) {
        Task {
            await mixer.append(buffer, when: time)
        }
    }
}
