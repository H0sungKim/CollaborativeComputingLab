//
//  SessionDescription.swift
//  WebRTC-Demo
//
//  Created by Stasel on 20/02/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation

/// This enum is a swift wrapper over `RTCSdpType` for easy encode and decode
public enum SdpType: String, Codable {
    case offer
    case prAnswer
    case answer
    case rollback
}

/// This struct is a swift wrapper over `RTCSessionDescription` for easy encode and decode
public struct SessionDescription: Entity {
    public let sdp: String
    public let type: SdpType
    
    public init(sdp: String, type: SdpType) {
        self.sdp = sdp
        self.type = type
    }
}
