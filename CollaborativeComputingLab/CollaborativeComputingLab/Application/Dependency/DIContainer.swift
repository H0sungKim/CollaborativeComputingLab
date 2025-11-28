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
    private lazy var rtmpService: RTMPService = makeRTMPService()
    private lazy var streamService: StreamService = makeStreamService()
    
    // MARK: - Init
    init(uri: String) {
        self.uri = uri
    }
    
    // MARK: - ViewControllerFactory
    func createHomeViewController(roomViewModel: RoomViewModel? = nil) -> HomeViewController {
        return HomeViewController.instantiate().configured({
            $0.inject(roomViewModel: roomViewModel ?? makeRoomViewModel())
        })
    }
    
    func createRoomViewController(id: String, userName: String, role: RoomRole, roomViewModel: RoomViewModel? = nil, chatViewModel: ChatViewModel? = nil, streamViewModel: StreamViewModel? = nil) -> RoomViewController {
        return RoomViewController.instantiate().configured({
            $0.inject(id: id, userName: userName, role: role, roomViewModel: roomViewModel ?? makeRoomViewModel(), chatViewModel: chatViewModel ?? makeChatViewModel(), streamViewModel: streamViewModel ?? makeStreamViewModel())
        })
    }
    
    // MARK: - ChatFactory
    func makeChatService() -> ChatService {
        return DefaultChatService(webSocket: webSocket)
    }
    
    // MARK: - StreamFactory
    func makeRTMPService() -> RTMPService {
        return RTMPService(uri: uri)
    }
    
    func makeStreamService() -> StreamService {
        return StreamService()
    }
    
    // MARK: - RoomFactory
    func makeRoomService() -> RoomService {
        return DefaultRoomService(webSocket: webSocket)
    }
}
