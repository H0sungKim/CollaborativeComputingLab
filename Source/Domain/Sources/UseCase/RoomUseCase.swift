//
//  RoomUseCase.swift
//  Domain
//
//  Created by 김호성 on 2025.07.01.
//

import Combine
import Foundation

import Entity
import Repository

public protocol RoomUseCase {
    var roomListStream: AnyPublisher<[RoomEntity], Never> { get }
    var participantListStream: AnyPublisher<[ParticipantEntity], Never> { get }
    var roomClosedStream: AnyPublisher<Void, Never> { get }
    
    func requestRoomList()
    func enterRoom(roomEntranceEntity: RoomEntranceEntity)
    func exitRoom(roomExitEntity: RoomExitEntity)
    func connectWebSocket()
}

public final class DefaultRoomUseCase: RoomUseCase {
    
    private let roomRepository: RoomRepository
    
    public init(roomRepository: RoomRepository) {
        self.roomRepository = roomRepository
    }
    
    public var roomListStream: AnyPublisher<[RoomEntity], Never> {
        return roomRepository.roomListStream
    }
    
    public var participantListStream: AnyPublisher<[ParticipantEntity], Never> {
        return roomRepository.participantListStream
    }
    
    public var roomClosedStream: AnyPublisher<Void, Never> {
        return roomRepository.roomClosedStream
    }
    
    public func requestRoomList() {
        roomRepository.requestRoomList()
    }
    
    public func enterRoom(roomEntranceEntity: RoomEntranceEntity) {
        roomRepository.enterRoom(roomEntranceEntity: roomEntranceEntity)
    }
    
    public func exitRoom(roomExitEntity: RoomExitEntity) {
        roomRepository.exitRoom(roomExitEntity: roomExitEntity)
    }
    
    public func connectWebSocket() {
        roomRepository.connectWebSocket()
    }
}
