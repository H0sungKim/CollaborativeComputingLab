//
//  RTCIceConnectionState.swift
//  Data
//
//  Created by 김호성 on 2025.06.24.
//

import Domain

import Foundation
import WebRTC

extension RTCIceConnectionState {
    var iceConnectionState: IceConnectionState {
        switch self {
        case .new:          return .new
        case .checking:     return .checking
        case .connected:    return .connected
        case .completed:    return .completed
        case .failed:       return .failed
        case .disconnected: return .disconnected
        case .closed:       return .closed
        case .count:        return .count
        @unknown default:
            fatalError("Unknown RTCIceConnectionState: \(self.rawValue)")
        }
    }
}
    
