//
//  AppDIProvider.swift
//  CleanArchitectureMVVM
//
//  Created by 김호성 on 2025.03.04.
//

import Presentation

import Foundation
import UIKit

class AppDIProvider: ViewControllerFactory {
    
    private let chatDIProvider: ChatDIProvider
    private let streamDIProvider: StreamDIProvider
    
    init() {
        self.chatDIProvider = DefaultChatDIProvider()
        self.streamDIProvider = DefaultStreamDIProvider()
    }
    
    init(chatDIProvider: ChatDIProvider, streamDIProvider: StreamDIProvider) {
        self.chatDIProvider = chatDIProvider
        self.streamDIProvider = streamDIProvider
    }
    
    func createHomeViewController() -> HomeViewController {
        let viewController: HomeViewController = HomeViewController.create()
        return viewController
    }
    
    func createRoomViewController(id: String, role: RoomRole, chatViewModel: ChatViewModel? = nil, streamViewModel: StreamViewModel? = nil) -> RoomViewController {
        let viewController: RoomViewController = RoomViewController.create()
        viewController.inject(id: id, role: role, chatViewModel: chatViewModel ?? chatDIProvider.makeChatViewModel(), streamViewModel: streamViewModel ?? streamDIProvider.makeStreamViewModel())
        return viewController
    }
}
