//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.07.01.
//

import Foundation
import Combine

public protocol RoomRepository {
    var roomListStream: AnyPublisher<[RoomEntity], Never> { get }
    var participantListStream: AnyPublisher<[ParticipantEntity], Never> { get }
    var roomClosedStream: AnyPublisher<Void, Never> { get }
    
    func requestRoomList()
    func enterRoom(roomEntranceEntity: RoomEntranceEntity)
    func exitRoom(roomExitEntity: RoomExitEntity)
    func connectWebSocket()
}
