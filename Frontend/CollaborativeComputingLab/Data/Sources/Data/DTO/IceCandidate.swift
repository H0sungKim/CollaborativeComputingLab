//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.06.19.
//

import Domain

import Foundation
import WebRTC

extension RTCIceCandidate {
    convenience init(iceCandidate: IceCandidate) {
        self.init(sdp: iceCandidate.sdp, sdpMLineIndex: iceCandidate.sdpMLineIndex, sdpMid: iceCandidate.sdpMid)
    }
    
    var iceCandidate: IceCandidate {
        return IceCandidate(sdp: sdp, sdpMLineIndex: sdpMLineIndex, sdpMid: sdpMid)
    }
}
