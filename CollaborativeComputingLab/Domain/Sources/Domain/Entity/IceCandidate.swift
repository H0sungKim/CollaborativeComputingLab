//
//  IceCandidate.swift
//  WebRTC-Demo
//
//  Created by Stasel on 20/02/2019.
//  Copyright © 2019 Stasel. All rights reserved.
//

import Foundation

/// This struct is a swift wrapper over `RTCIceCandidate` for easy encode and decode
public struct IceCandidate: Entity {
    public let sdp: String
    public let sdpMLineIndex: Int32
    public let sdpMid: String?
    
    public init(sdp: String, sdpMLineIndex: Int32, sdpMid: String?) {
        self.sdp = sdp
        self.sdpMLineIndex = sdpMLineIndex
        self.sdpMid = sdpMid
    }
}
