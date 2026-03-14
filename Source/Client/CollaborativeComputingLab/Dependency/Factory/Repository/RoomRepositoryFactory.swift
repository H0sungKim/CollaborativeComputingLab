//
//  RoomRepositoryFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2026.03.12.
//

import Foundation

import Data
import Domain

protocol RoomRepositoryFactory: RoomServiceFactory {
    func makeRoomRepository() -> RoomRepository
}

extension RoomRepositoryFactory {
    func makeRoomRepository() -> RoomRepository {
        return DefaultRoomRepository(roomService: makeRoomService())
    }
}
