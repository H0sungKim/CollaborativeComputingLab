//
//  RoomServiceFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.03.12.
//

import Foundation

import Data

protocol RoomServiceFactory: WebSocketFactory {
    func makeRoomService() -> RoomService
}

extension RoomServiceFactory {
    func makeRoomService() -> RoomService {
        return DefaultRoomService(webSocket: makeWebSocket())
    }
}
