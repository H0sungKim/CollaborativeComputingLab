//
//  RoomService.swift
//  Data
//
//  Created by 김호성 on 2025.06.28.
//

import Domain

import Foundation
import Combine

public protocol RoomService {
    var roomListStream: PassthroughSubject<RoomListDTO, Never> { get }
    var participantListStream: PassthroughSubject<ParticipantListDTO, Never> { get }
    var roomClosed: PassthroughSubject<Void, Never> { get }
    
    func requestRoomList()
    func enterRoom(roomEntranceDTO: RoomEntranceDTO)
    func exitRoom(roomExitDTO: RoomExitDTO)
    func connectWebSocket()
}

public final class DefaultRoomService: RoomService {
    public var roomListStream: PassthroughSubject<RoomListDTO, Never> = .init()
    public var participantListStream: PassthroughSubject<ParticipantListDTO, Never> = .init()
    public var roomClosed: PassthroughSubject<Void, Never> = .init()
    
    private let webSocket: WebSocket
    
    private var cancellable: Set<AnyCancellable> = Set<AnyCancellable>()
    
    public init(webSocket: WebSocket) {
        self.webSocket = webSocket
    }
    
    func receive() {
        webSocket.dataStream.sinkHandledCompletion(receiveValue: { [weak self] data in
            guard let message = JSONManager.shared.decode(data: data, type: ServerMessage.self) else { return }
            switch message {
            case .availableRooms(let roomListDTO):
                Log.log("WebSocket received availableRooms: \(roomListDTO)")
                self?.roomListStream.send(roomListDTO)
            case .participantUpdated(let participantListDTO):
                Log.log("WebSocket received participantUpdated: \(participantListDTO)")
                self?.participantListStream.send(participantListDTO)
            case .roomClosed:
                Log.log("WebSocket received roomClosed.")
                self?.roomClosed.send(())
            default:
                break
            }
        })
        .store(in: &cancellable)
    }
    
    public func requestRoomList() {
        Log.log("Sending requestRoomList message.")
        guard let messageData = JSONManager.shared.encode(codable: ClientMessage.requestRoomList) else { return }
        webSocket.send(data: messageData)
    }
    
    public func enterRoom(roomEntranceDTO: RoomEntranceDTO) {
        Log.log("Sending enterRoom message: \(roomEntranceDTO)")
        guard let messageData = JSONManager.shared.encode(codable: ClientMessage.enterRoom(roomEntranceDTO)) else { return }
        webSocket.send(data: messageData)
    }
    
    public func exitRoom(roomExitDTO: RoomExitDTO) {
        Log.log("Sending exitRoom message: \(roomExitDTO)")
        guard let messageData = JSONManager.shared.encode(codable: ClientMessage.leaveRoom (roomExitDTO)) else { return }
        webSocket.send(data: messageData)
    }
    
    public func connectWebSocket() {
        if webSocket.isConnected.value {
            return
        }
        webSocket.connect()
        receive()
    }
}
