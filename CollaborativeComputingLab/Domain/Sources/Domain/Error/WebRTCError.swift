//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation

public enum WebRTCError: Error {
    case offerSdpFailed(error: Error?)
    case answerSdpFailed(error: Error?)
    case setLocalSdpFailed(error: Error?)
    case setRemoteSdpFailed(error: Error?)
    case addRemoteCandidateFailed(error: Error?)
}

extension WebRTCError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .offerSdpFailed(let error):
            return "Failed to create offer SDP.\n\(error?.localizedDescription ?? "")"
        case .answerSdpFailed(let error):
            return "Failed to create answer SDP.\n\(error?.localizedDescription ?? "")"
        case .setLocalSdpFailed(let error):
            return "Failed to set local SDP.\n\(error?.localizedDescription ?? "")"
        case .setRemoteSdpFailed(let error):
            return "Failed to set remote SDP.\n\(error?.localizedDescription ?? "")"
        case .addRemoteCandidateFailed(let error):
            return "Failed to add remote candidate.\n\(error?.localizedDescription ?? "")"
        }
    }
}
