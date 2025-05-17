//
//  StreamRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.05.10.
//

import Domain

import Foundation
import UIKit

import HaishinKit

public final class DefaultStreamRepository: StreamRepository {
    
    private let rtmpService: RTMPService
    
    public init(rtmpService: RTMPService) {
        self.rtmpService = rtmpService
    }
    
    public func publish() async throws {
        try await rtmpService.publish()
    }
    
    public func play() async throws {
        try await rtmpService.play()
    }
    
    public func close() async {
        await rtmpService.close()
    }
    
    public func addOutputView(_ view: UIView) async {
        if let output = view as? (any HKStreamOutput) {
            await rtmpService.addOutput(output)
        }
    }
    
    public func addOutputStreamToMixer(mixer: Any) async {
        if let mixer = mixer as? MediaMixer {
            await rtmpService.addOutputStreamToMixer(mixer: mixer)
        }
    }
    
    public func attachAudioPlayer(audioPlayer: Any) async {
        if let audioPlayer = audioPlayer as? AudioPlayer {
            await rtmpService.attachAudioPlayer(audioPlayer: audioPlayer)
        }
    }
}
