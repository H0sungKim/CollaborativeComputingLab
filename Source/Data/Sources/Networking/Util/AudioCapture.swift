//
//  AudioCapture.swift
//  Data
//
//  Created by 김호성 on 2025.04.27.
//

import AVFoundation
import Foundation

import HaishinKit

import Domain
import Log

protocol AudioEngineCaptureDelegate: AnyObject {
    func audioCapture(_ audioCapture: AudioEngineCapture, buffer: AVAudioPCMBuffer, time: AVAudioTime)
}

final class AudioEngineCapture {
    weak var delegate: (any AudioEngineCaptureDelegate)?
    
    private(set) var isRunning = false
    private let audioEngine: AVAudioEngine
    
    init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
    }
    
    func startCaptureIfNeeded() {
        guard isRunning else {
            return
        }
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        do {
            try startCapture()
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    private func startCapture() throws {
        let input = audioEngine.inputNode
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(input, to: mixer, format: input.inputFormat(forBus: 0))
        input.installTap(onBus: 0, bufferSize: 1024, format: input.inputFormat(forBus: 0)) { buffer, when in
            self.delegate?.audioCapture(self, buffer: buffer, time: when)
        }
        audioEngine.prepare()
        try audioEngine.start()
    }
}

extension AudioEngineCapture: Runner {
    func startRunning() {
        guard !isRunning else {
            return
        }
        do {
            try startCapture()
            isRunning = true
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    func stopRunning() {
        guard isRunning else {
            return
        }
        audioEngine.stop()
        isRunning = false
    }
}
