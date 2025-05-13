//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.05.12.
//

import Foundation
import UIKit

public protocol StreamUseCase: Sendable {
    func open(method: StreamRole) async
    func close() async
    func addOutputView(_ view: UIView) async
    func addOutputStreamToMixer(mixer: Any) async
    func attachAudioPlayer(audioPlayer: Any) async
}

public final class DefaultStreamUseCase: StreamUseCase {
    
    private let streamRepository: StreamRepository
    
    public init(streamRepository: StreamRepository) {
        self.streamRepository = streamRepository
    }
    
    public func open(method: StreamRole) async {
        await streamRepository.open(method: method)
    }
    
    public func close() async {
        await streamRepository.close()
    }
    public func addOutputView(_ view: UIView) async {
        await streamRepository.addOutputView(view)
    }
    
    public func addOutputStreamToMixer(mixer: Any) async {
        await streamRepository.addOutputStreamToMixer(mixer: mixer)
    }
    
    public func attachAudioPlayer(audioPlayer: Any) async {
        await streamRepository.attachAudioPlayer(audioPlayer: audioPlayer)
    }
}
