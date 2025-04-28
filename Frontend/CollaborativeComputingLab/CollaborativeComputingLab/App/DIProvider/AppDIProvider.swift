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
    
    init() {
        self.chatDIProvider = DefaultChatDIProvider()
    }
    
    init(chatDIProvider: ChatDIProvider) {
        self.chatDIProvider = chatDIProvider
    }
    
    func createHomeViewController() -> HomeViewController {
        let viewController: HomeViewController = HomeViewController.create()
        return viewController
    }
    
    func createRoomViewController(id: String, chatViewModel: ChatViewModel? = nil) -> RoomViewController {
        let viewController: RoomViewController = RoomViewController.create()
        viewController.inject(id: id, chatViewModel: chatViewModel ?? chatDIProvider.makeChatViewModel())
        return viewController
    }
}
