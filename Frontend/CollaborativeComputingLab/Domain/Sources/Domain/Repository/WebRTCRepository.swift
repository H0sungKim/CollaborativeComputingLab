//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation
import Combine

public protocol WebRTCRepository {
    var localCandidateSubject: AnyPublisher<IceCandidate, Never> { get }
    
    func offer() -> AnyPublisher<SessionDescription, WebRTCError>
    func answer() -> AnyPublisher<SessionDescription, WebRTCError>
    func setRemoteSdp(_ remoteSdp: SessionDescription)
    func setRemoteCandidate(_ remoteCandidate: IceCandidate)
}
