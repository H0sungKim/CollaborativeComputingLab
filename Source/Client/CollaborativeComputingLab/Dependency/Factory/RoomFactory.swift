//
//  RoomFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.07.02.
//

import Foundation

import Data
import Domain
import Presentation

protocol RoomFactory {
    func buildRoomRepository() -> RoomRepository
    func buildRoomRepository(roomService: RoomService) -> RoomRepository
    
    func buildRoomUseCase() -> RoomUseCase
    func buildRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase
    
    func buildRoomViewModel() -> RoomViewModel
    func buildRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel
}

extension RoomFactory {
    func buildRoomRepository(roomService: RoomService) -> RoomRepository {
        return DefaultRoomRepository(roomService: roomService)
    }
    
    func buildRoomUseCase() -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: buildRoomRepository())
    }
    func buildRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: roomRepository)
    }
    
    func buildRoomViewModel() -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: buildRoomUseCase())
    }
    func buildRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: roomUseCase)
    }
}
