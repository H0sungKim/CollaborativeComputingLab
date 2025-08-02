//
//  AudioCapture.swift
//  Data
//
//  Created by 김호성 on 2025.04.27.
//

import Domain

import AVFoundation
import Foundation

import HaishinKit

public protocol AudioCaptureDelegate: AnyObject {
    func audioCapture(_ audioCapture: AudioCapture, buffer: AVAudioBuffer, time: AVAudioTime)
}

public final class AudioCapture {
    public var isRunning = false
    weak var delegate: (any AudioCaptureDelegate)?
    private let audioEngine: AVAudioEngine
    
    init(audioEngine: AVAudioEngine) {
        self.audioEngine = audioEngine
    }
}

extension AudioCapture: Runner {
    public func startRunning() {
        guard !isRunning else {
            return
        }
        let input = audioEngine.inputNode
        let mixer = audioEngine.mainMixerNode
        audioEngine.connect(input, to: mixer, format: input.inputFormat(forBus: 0))
        input.installTap(onBus: 0, bufferSize: 1024, format: input.inputFormat(forBus: 0)) { buffer, when in
            self.delegate?.audioCapture(self, buffer: buffer, time: when)
        }
        do {
            try audioEngine.start()
            isRunning = true
        } catch {
            Log.e(error.localizedDescription)
        }
    }

    public func stopRunning() {
        guard isRunning else {
            return
        }
        audioEngine.stop()
        isRunning = false
    }
}
