//
//  RoomViewModel.swift
//  Presentation
//
//  Created by 김호성 on 2025.07.01.
//

import Foundation
import Combine

import Domain

public protocol RoomViewModelInput {
    func requestRoomList()
    func enterRoom(id: String, userName: String)
    func exitRoom(id: String)
    func connectWebSocket()
}

public protocol RoomViewModelOutput {
    var availableRooms: CurrentValueSubject<[RoomEntity], Never> { get }
    var participants: CurrentValueSubject<[ParticipantEntity], Never> { get }
    var roomClosed: AnyPublisher<Void, Never> { get }
}

public protocol RoomViewModel: RoomViewModelInput, RoomViewModelOutput { }

public final class DefaultRoomViewModel: RoomViewModel {
    
    private let roomUseCase: RoomUseCase
    
    public var availableRooms: CurrentValueSubject<[RoomEntity], Never> = .init([])
    public var participants: CurrentValueSubject<[ParticipantEntity], Never> = .init([])
    
    public var roomClosed: AnyPublisher<Void, Never> {
        return roomUseCase.roomClosedStream
            .manageThread()
    }
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(roomUseCase: RoomUseCase) {
        self.roomUseCase = roomUseCase
        bind()
    }
    
    private func bind() {
        roomUseCase.roomListStream
            .manageThread()
            .sinkHandledCompletion(receiveValue: { [weak self] roomListEntity in
                self?.availableRooms.value = roomListEntity
            })
            .store(in: &cancellable)
        
        roomUseCase.participantListStream
            .manageThread()
            .sinkHandledCompletion(receiveValue: { [weak self] participantListEntity in
                self?.participants.value = participantListEntity
            })
            .store(in: &cancellable)
    }
    
    public func requestRoomList() {
        roomUseCase.requestRoomList()
    }
    
    public func enterRoom(id: String, userName: String) {
        roomUseCase.enterRoom(roomEntranceEntity: RoomEntranceEntity(id: id, userName: userName))
    }
    
    public func exitRoom(id: String) {
        roomUseCase.exitRoom(roomExitEntity: RoomExitEntity(id: id))
    }
    
    public func connectWebSocket() {
        roomUseCase.connectWebSocket()
    }
}
