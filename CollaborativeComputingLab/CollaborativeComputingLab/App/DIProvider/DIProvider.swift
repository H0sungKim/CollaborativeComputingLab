//
//  AppDIProvider.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.03.04.
//

import Data
import Domain
import Presentation

import Foundation
import UIKit

protocol DIProvider: ViewControllerFactory, ChatDIProvider, StreamDIProvider, RoomDIProvider { }

class DefaultDIProvider: DIProvider {
    
    private let uri: String
    private let webSocket: WebSocket
    
    init(uri: String) {
        self.uri = uri
        self.webSocket = WebSocket(url: URL(string: "ws://\(uri):8080")!)
    }
    
    // MARK: - ViewControllerFactory
    func createHomeViewController(roomViewModel: RoomViewModel? = nil) -> HomeViewController {
        let viewController: HomeViewController = HomeViewController.create()
        viewController.inject(roomViewModel: roomViewModel ?? makeRoomViewModel())
        return viewController
    }
    
    func createRoomViewController(id: String, role: RoomRole, roomViewModel: RoomViewModel? = nil, chatViewModel: ChatViewModel? = nil, streamViewModel: StreamViewModel? = nil) -> RoomViewController {
        let viewController: RoomViewController = RoomViewController.create()
        viewController.inject(id: id, role: role, roomViewModel: roomViewModel ?? makeRoomViewModel(), chatViewModel: chatViewModel ?? makeChatViewModel(), streamViewModel: streamViewModel ?? makeStreamViewModel())
        return viewController
    }
    
    // MARK: - ChatDIProvider
    func makeChatRepository() -> ChatRepository {
        return DefaultChatRepository(chatService: DefaultChatService(webSocket: webSocket))
    }
    func makeChatRepository(chatService: ChatService) -> ChatRepository {
        return DefaultChatRepository(chatService: chatService)
    }
    
    func makeChatUseCase() -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: makeChatRepository())
    }
    func makeChatUseCase(chatRepository: ChatRepository) -> ChatUseCase {
        return DefaultChatUseCase(chatRepository: chatRepository)
    }
    
    func makeChatViewModel() -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: makeChatUseCase())
    }
    func makeChatViewModel(chatUseCase: ChatUseCase) -> ChatViewModel {
        return DefaultChatViewModel(chatUseCase: chatUseCase)
    }
    
    // MARK: - StreamDIProvider
    func makeStreamRepository() -> StreamRepository {
        return DefaultStreamRepository(rtmpService: RTMPService(uri: uri), streamService: StreamService())
    }
    func makeStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository {
        return DefaultStreamRepository(rtmpService: rtmpService, streamService: streamService)
    }
    
    func makeStreamUseCase() -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: makeStreamRepository())
    }
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: streamRepository)
    }
    
    func makeStreamViewModel() -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: makeStreamUseCase())
    }
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: streamUseCase)
    }
    
    // MARK: - RoomDIProvider
    func makeRoomRepository() -> RoomRepository {
        return DefaultRoomRepository(roomService: DefaultRoomService(webSocket: webSocket))
    }
    func makeRoomRepository(roomService: RoomService) -> RoomRepository {
        return DefaultRoomRepository(roomService: roomService)
    }
    
    func makeRoomUseCase() -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: makeRoomRepository())
    }
    func makeRoomUseCase(roomRepository: RoomRepository) -> RoomUseCase {
        return DefaultRoomUseCase(roomRepository: roomRepository)
    }
    
    func makeRoomViewModel() -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: makeRoomUseCase())
    }
    func makeRoomViewModel(roomUseCase: RoomUseCase) -> RoomViewModel {
        return DefaultRoomViewModel(roomUseCase: roomUseCase)
    }
}
