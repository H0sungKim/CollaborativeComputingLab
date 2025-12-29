//
//  RoomRepositoryImpl.swift
//  Data
//
//  Created by 김호성 on 2025.07.01.
//

import DTO
import Networking

import Domain

import Combine
import Foundation

public final class DefaultRoomRepository: RoomRepository {
    
    private let roomService: RoomService
    
    public var roomListStream: AnyPublisher<[RoomEntity], Never> {
        return roomService.roomListStream
            .map(\.entities)
            .eraseToAnyPublisher()
    }
    
    public var participantListStream: AnyPublisher<[ParticipantEntity], Never> {
        return roomService.participantListStream
            .map(\.entities)
            .eraseToAnyPublisher()
    }
    
    public var roomClosedStream: AnyPublisher<Void, Never> {
        return roomService.roomClosed
            .eraseToAnyPublisher()
    }
    
    public init(roomService: RoomService) {
        self.roomService = roomService
    }
    
    public func requestRoomList() {
        roomService.requestRoomList()
    }
    
    public func enterRoom(roomEntranceEntity: RoomEntranceEntity) {
        roomService.enterRoom(roomEntranceDTO: RoomEntranceDTO(entity: roomEntranceEntity))
    }
    
    public func exitRoom(roomExitEntity: RoomExitEntity) {
        roomService.exitRoom(roomExitDTO: RoomExitDTO(entity: roomExitEntity))
    }
    
    public func connectWebSocket() {
        roomService.connectWebSocket()
    }
}
