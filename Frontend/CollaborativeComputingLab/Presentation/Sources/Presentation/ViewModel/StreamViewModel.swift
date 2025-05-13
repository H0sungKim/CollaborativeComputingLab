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

public protocol StreamViewModelInput {
    func open(method: StreamRole) async
    func close() async
    func addOutputView(_ view: UIView) async
    func addOutputStreamToMixer() async
    func attachAudioPlayer(audioPlayer: AudioPlayer) async
}

public protocol StreamViewModelOutput {
    var mixer: MediaMixer { get }
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput, Sendable { }

public final actor DefaultStreamViewModel: StreamViewModel {
    
    public let mixer: MediaMixer = MediaMixer(multiCamSessionEnabled: true, multiTrackAudioMixingEnabled: true, useManualCapture: true)
    
    private let streamUseCase: StreamUseCase
    
    public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func open(method: StreamRole) async {
        await streamUseCase.open(method: method)
    }
    
    public func close() async {
        await streamUseCase.close()
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
}
