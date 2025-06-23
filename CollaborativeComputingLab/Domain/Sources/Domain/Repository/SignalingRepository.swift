//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation
import Combine

public protocol SignalingRepository {
    var isConnected: CurrentValueSubject<Bool, Never> { get }
    var sdpSubject: AnyPublisher<SessionDescription, Never> { get }
    var candidateSubject: AnyPublisher<IceCandidate, Never> { get }
    
    func sendSdp(_ sdp: SessionDescription)
    func sendCandidate(_ iceCandidate: IceCandidate)
}
