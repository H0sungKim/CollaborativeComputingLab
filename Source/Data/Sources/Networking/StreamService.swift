//
//  StreamService.swift
//  Data
//
//  Created by 김호성 on 2025.05.18.
//

import Log

import Domain

import AVFoundation
import Foundation

import HaishinKit
import RTMPHaishinKit

public final actor StreamService {
    private let mixer: MediaMixer = MediaMixer(captureSessionMode: .single, multiTrackAudioMixingEnabled: true)
    private var audioCapture: AudioEngineCapture!
    @ScreenActor private lazy var videoScreenObject: VideoTrackScreenObject = VideoTrackScreenObject()
    private var audioPlayer: AudioPlayer!
    
    public init() {
        
    }
    
    package func attachMedia(video: sending AVCaptureDevice?, audio: sending AVCaptureDevice?) async {
        do {
            try await mixer.attachVideo(video, track: 1) { videoUnit in
                videoUnit.isVideoMirrored = true
            }
            try await mixer.attachAudio(audio, track: 0)
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func detachMedia() async {
        do {
            try await mixer.attachAudio(nil)
            try await mixer.attachVideo(nil, track: 0)
            try await mixer.attachVideo(nil, track: 1)
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func startMixer() async {
        await mixer.startRunning()
    }
    
    package func stopMixer() async {
        await mixer.stopRunning()
    }
    
    @ScreenActor package func setScreenSize(orientation: AVCaptureVideoOrientation) async {
        switch orientation {
        case .portrait, .portraitUpsideDown:
            mixer.screen.size = CGSize(width: 720, height: 1280)
        case .landscapeRight, .landscapeLeft:
            mixer.screen.size = CGSize(width: 1280, height: 720)
        @unknown default:
            Log.e("Unknown orientation")
        }
    }
    
    @ScreenActor package func configureScreen(orientation: AVCaptureVideoOrientation) async {
        await setScreenSize(orientation: orientation)
        mixer.screen.backgroundColor = CGColor(gray: 0, alpha: 0)
    }
    
    @ScreenActor package func configureVideoScreenObject() async {
        videoScreenObject.cornerRadius = 16.0
        videoScreenObject.track = 1
        videoScreenObject.horizontalAlignment = .right
//        videoScreenObject.layoutMargin = NSEdgeInsets(top: 16, left: 0, bottom: 0, right: 16)
        videoScreenObject.size = CGSize(width: 160 * 2, height: 90 * 2)
        do {
            try mixer.screen.addChild(videoScreenObject)
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func configureAudio(audioEngine: AVAudioEngine) {
        Task {
            audioPlayer = AudioPlayer(audioEngine: audioEngine)
        }
        audioCapture = AudioEngineCapture(audioEngine: audioEngine)
    }
    
    package func configureVideoMixerSettings() async {
        var videoMixerSettings = await mixer.videoMixerSettings
        videoMixerSettings.mode = .offscreen
        await mixer.setVideoMixerSettings(videoMixerSettings)
    }
    
    package func setAudioCaptureDelegate() {
        audioCapture.delegate = self
    }
    
    package func removeAudioCaptureDelegate() {
        audioCapture.delegate = nil
    }
    
    package func setMonitoringEnabled(_ monitoringEnabled: Bool) async {
        await mixer.setMonitoringEnabled(monitoringEnabled)
    }
    
    package func setVideoOrientation(_ orientation: AVCaptureVideoOrientation) async {
        await mixer.setVideoOrientation(orientation)
    }
    
    package func getAudioPlayer() -> AudioPlayer {
        return audioPlayer
    }
    
    package func addOutputStream(stream: RTMPStream) async {
        await mixer.addOutput(stream)
    }
    
    package func appendBuffer(_ sampleBuffer: CMSampleBuffer) async {
        await mixer.append(sampleBuffer, track: 0)
    }
}

extension StreamService: @preconcurrency AudioEngineCaptureDelegate {
    func audioCapture(_ audioCapture: AudioEngineCapture, buffer: AVAudioPCMBuffer, time: AVAudioTime) {
        Task {
            await mixer.append(buffer, when: time)
        }
    }
}
