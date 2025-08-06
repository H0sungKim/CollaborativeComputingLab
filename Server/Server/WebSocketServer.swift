//
//  WebSocketServer.swift
//  Server
//
//  Created by 김호성 on 2025.06.24.
//

import Foundation
import Network

final class WebSocketServer {
    
    private let queue = DispatchQueue.global()
    private let port: NWEndpoint.Port = 8080
    private let listener: NWListener
    private var connectedClients = Set<WebSocketClient>()
    private var chatRooms: [String: Room] = [:]
    
    init() throws {
        let parameters = NWParameters.tcp
        let webSocketOptions = NWProtocolWebSocket.Options()
        webSocketOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.append(webSocketOptions)
        listener = try NWListener(using: parameters, on: port)
    }
    
    func start() {
        listener.newConnectionHandler = newConnectionHandler
        listener.start(queue: queue)
        Log.i("Server started listening on port \(port)")
    }
    
    private func newConnectionHandler(_ connection: NWConnection) {
        let client = WebSocketClient(connection: connection)
        connectedClients.insert(client)
        client.connection.start(queue: queue)
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
        let roomEntityList: [RoomEntity] = chatRooms.values.map(\.roomEntity)
        if let encoded = JSONManager.shared.encode(codable: ServerMessage.availableRooms(RoomListDTO(entities: roomEntityList))) {
            broadcast(data: encoded, to: [client])
        }
        Log.i("A client has connected. Total connected clients: \(connectedClients.count)")
    }
    
    private func didDisconnect(client: WebSocketClient) {
        chatRooms.values.forEach({ room in
            if room.removeClient(client) {
                if !room.isAvailable {
                    closeRoom(id: room.id)
                    chatRooms.removeValue(forKey: room.id)
                } else {
                    broadcastParticipants(id: room.id)
                }
                broadcastAvailableRooms(to: connectedClients)
            }
        })
        Log.i("A client has disconnected. Total connected clients: \(connectedClients.count)")
    }
    
    private func didReceiveMessage(from client: WebSocketClient,
                                   data: Data?,
                                   context: NWConnection.ContentContext?,
                                   error: NWError?) {
        
        if let context = context, context.isFinal {
            client.connection.cancel()
            didDisconnect(client: client)
            return
        }
        
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
        
        guard let data, let message = JSONManager.shared.decode(data: data, type: ClientMessage.self) else { return }
        
        switch message {
        case .requestRoomList:
            Log.i("Received request for room list.")
            broadcastAvailableRooms(to: [client])
        case .enterRoom(let roomEntranceDTO):
            let entity = roomEntranceDTO.entity
            Log.i(entity)
            client.name = entity.userName
            let room: Room = {
                guard let room = chatRooms[entity.id] else {
                    chatRooms[entity.id] = Room(id: entity.id, instructor: client)
                    return chatRooms[entity.id]!
                }
                return room
            }()
            room.addClient(client)
            
            broadcastAvailableRooms(to: connectedClients)
            broadcastParticipants(id: entity.id)
        case .leaveRoom(let roomExitDTO):
            let entity = roomExitDTO.entity
            Log.i(entity)
            chatRooms[entity.id]?.removeClient(client)
            
            if !(chatRooms[entity.id]?.isAvailable ?? false) {
                closeRoom(id: entity.id)
                chatRooms.removeValue(forKey: entity.id)
            } else {
                broadcastParticipants(id: entity.id)
            }
            
            broadcastAvailableRooms(to: connectedClients)
        case .sendChat(let messageDTO):
            let entity = messageDTO.entity
            Log.i(entity)
            broadcastMessage(message: entity, sender: client)
        }
    }
    
    private func broadcast(data: Data, to clients: Set<WebSocketClient>) {
        clients.forEach {
            let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
            let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

            $0.connection.send(
                content: data,
                contentContext: context,
                isComplete: true,
                completion: .contentProcessed({ _ in })
            )
        }
    }
    
    private func broadcastAvailableRooms(to clients: Set<WebSocketClient>) {
        let message = ServerMessage.availableRooms(getRoomListDTO())
        Log.i(message)
        guard let messageData = JSONManager.shared.encode(codable: message) else { return }
        broadcast(data: messageData, to: clients)
    }
    
    private func getRoomListDTO() -> RoomListDTO {
        return RoomListDTO(rooms: chatRooms.map({ (id, room) in
            RoomListDTO.RoomDTO(id: id, participants: room.clients.compactMap(\.name))
        }))
    }
    
    private func broadcastParticipants(id: String) {
        let message = ServerMessage.participantUpdated(getParticipantListDTO(id: id))
        Log.i(message)
        guard let messageData = JSONManager.shared.encode(codable: message) else { return }
        broadcast(data: messageData, to: Set(chatRooms[id]?.clients ?? []))
    }
    
    private func getParticipantListDTO(id: String) -> ParticipantListDTO {
        return ParticipantListDTO(participants: chatRooms[id]?.clients.compactMap({ ParticipantListDTO.ParticipantDTO(name: $0.name) }))
    }
    
    private func closeRoom(id: String) {
        let message = ServerMessage.roomClosed
        Log.i(message)
        guard let messageData = JSONManager.shared.encode(codable: message) else { return }
        broadcast(data: messageData, to: Set(chatRooms[id]?.clients ?? []))
    }
    
    private func broadcastMessage(message: MessageEntity, sender: WebSocketClient) {
        let message = ServerMessage.newChat(ChatDTO(name: sender.name, message: message.message))
        Log.i(message)
        guard let messageData = JSONManager.shared.encode(codable: message) else { return }
        chatRooms.values.forEach({ room in
            if room.clients.contains(sender) {
                broadcast(data: messageData, to: Set(room.clients))
            }
        })
    }
}
