//
//  RoomFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.07.02.
//

import Data
import Domain
import Presentation

import Foundation

protocol RoomFactory {
    func makeRoomService() -> RoomService
    
    func makeRoomRepository() -> RoomRepository
    func makeRoomRepository(roomService: RoomService) -> RoomRepository
    
    func makeRoomUseCase() -> RoomUseCase
    func makeRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase
    
    func makeRoomViewModel() -> RoomViewModel
    func makeRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel
}

extension RoomFactory {
    func makeRoomRepository() -> RoomRepository {
        return DefaultRoomRepository(roomService: makeRoomService())
    }
    func makeRoomRepository(roomService: RoomService) -> RoomRepository {
        return DefaultRoomRepository(roomService: roomService)
    }
    
    func makeRoomUseCase() -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: makeRoomRepository())
    }
    func makeRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: roomRepository)
    }
    
    func makeRoomViewModel() -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: makeRoomUseCase())
    }
    func makeRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: roomUseCase)
    }
}
