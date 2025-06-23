//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.06.19.
//

import Domain

import WebRTC
import Foundation

extension RTCSdpType {
    init(sdpType: SdpType) {
        switch sdpType {
        case .offer:
            self = .offer
        case .prAnswer:
            self = .prAnswer
        case .answer:
            self = .answer
        case .rollback:
            self = .rollback
        }
    }
    
    var sdpType: SdpType {
        switch self {
        case .offer:
            return .offer
        case .prAnswer:
            return .prAnswer
        case .answer:
            return .answer
        case .rollback:
            return .rollback
        @unknown default:
            fatalError("Unknown RTCSessionDescription type: \(self)")
        }
    }
}

extension RTCSessionDescription {
    convenience init(sessionDescription: SessionDescription) {
        self.init(type: RTCSdpType(sdpType: sessionDescription.type), sdp: sessionDescription.sdp)
    }
    
    var sessionDescription: SessionDescription {
        return SessionDescription(sdp: sdp, type: type.sdpType)
    }
}
