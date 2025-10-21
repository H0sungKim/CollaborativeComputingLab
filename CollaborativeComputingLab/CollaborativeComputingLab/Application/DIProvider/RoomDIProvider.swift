//
//  RoomDIProvider.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.07.02.
//

import Data
import Domain
import Presentation

import Foundation

protocol RoomDIProvider {
    func makeRoomRepository() -> RoomRepository
    func makeRoomRepository(roomService: RoomService) -> RoomRepository
    
    func makeRoomUseCase() -> RoomUseCase
    func makeRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase
    
    func makeRoomViewModel() -> RoomViewModel
    func makeRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel
}
