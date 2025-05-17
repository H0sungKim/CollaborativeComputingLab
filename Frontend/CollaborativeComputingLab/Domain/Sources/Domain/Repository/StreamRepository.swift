//
//  StreamRepository.swift
//  Domain
//
//  Created by 김호성 on 2025.05.10.
//

import Foundation
import UIKit

public protocol StreamRepository: Sendable {
    func publish() async throws
    func play() async throws
    func close() async
    func addOutputView(_ view: UIView) async
    func addOutputStreamToMixer(mixer: Any) async
    func attachAudioPlayer(audioPlayer: Any) async
}
