//
//  DIContainer.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.04.
//

import Data
import Domain
import Presentation

import Foundation
import UIKit

protocol AppFactory: ViewControllerFactory, ChatFactory, StreamFactory, RoomFactory { }
typealias DIContainer = AppFactory

final class DefaultDIContainer: DIContainer {
    
    private let uri: String
    
    // MARK: - Root Dependency
    private lazy var webSocket: WebSocket = WebSocket(url: URL(string: "ws://\(uri):8080")!)
    private lazy var chatService: ChatService = DefaultChatService(webSocket: webSocket)
    private lazy var roomService: RoomService = DefaultRoomService(webSocket: webSocket)
    private lazy var rtmpService: RTMPService = RTMPService(uri: uri)
    private lazy var streamService: StreamService = StreamService()
    
    // MARK: - Init
    init(uri: String) {
        self.uri = uri
    }
    
    // MARK: - ViewControllerFactory
    func buildHomeViewController(roomViewModel: RoomViewModel? = nil) -> HomeViewController {
        return HomeViewController.instantiate().configured({
            $0.inject(roomViewModel: roomViewModel ?? buildRoomViewModel())
        })
    }
    
    func buildRoomViewController(id: String, userName: String, role: RoomRole, roomViewModel: RoomViewModel? = nil, chatViewModel: ChatViewModel? = nil, streamViewModel: StreamViewModel? = nil) -> RoomViewController {
        return RoomViewController.instantiate().configured({
            $0.inject(id: id, userName: userName, role: role, roomViewModel: roomViewModel ?? buildRoomViewModel(), chatViewModel: chatViewModel ?? buildChatViewModel(), streamViewModel: streamViewModel ?? buildStreamViewModel())
        })
    }
    
    // MARK: - Root Dependency Injection
    func buildChatRepository() -> ChatRepository {
        return buildChatRepository(chatService: chatService)
    }
    
    func buildStreamRepository() -> StreamRepository {
        return buildStreamRepository(rtmpService: rtmpService, streamService: streamService)
    }
    
    func buildRoomRepository() -> RoomRepository {
        return buildRoomRepository(roomService: roomService)
    }
}
