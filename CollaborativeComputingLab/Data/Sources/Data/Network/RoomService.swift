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
            guard let message = data.decode(type: ServerMessage.self) else { return }
            switch message {
            case .availableRooms(let roomListDTO):
                Log.i("WebSocket received availableRooms: \(roomListDTO)")
                self?.roomListStream.send(roomListDTO)
            case .participantUpdated(let participantListDTO):
                Log.i("WebSocket received participantUpdated: \(participantListDTO)")
                self?.participantListStream.send(participantListDTO)
            case .roomClosed:
                Log.i("WebSocket received roomClosed.")
                self?.roomClosed.send()
            default:
                break
            }
        })
        .store(in: &cancellable)
    }
    
    public func requestRoomList() {
        Log.i("Sending requestRoomList message.")
        guard let messageData = ClientMessage.requestRoomList.encode() else { return }
        webSocket.send(data: messageData)
    }
    
    public func enterRoom(roomEntranceDTO: RoomEntranceDTO) {
        Log.i("Sending enterRoom message: \(roomEntranceDTO)")
        guard let messageData = ClientMessage.enterRoom(roomEntranceDTO).encode() else { return }
        webSocket.send(data: messageData)
    }
    
    public func exitRoom(roomExitDTO: RoomExitDTO) {
        Log.i("Sending exitRoom message: \(roomExitDTO)")
        guard let messageData = ClientMessage.leaveRoom (roomExitDTO).encode() else { return }
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
