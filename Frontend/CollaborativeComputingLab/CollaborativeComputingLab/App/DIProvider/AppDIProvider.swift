//
//  AppDIProvider.swift
//  CleanArchitectureMVVM
//
//  Created by 김호성 on 2025.03.04.
//

import Foundation
import UIKit

public protocol ViewControllerFactory {
    func createRoomViewController(chatViewModel: ChatViewModel?) -> RoomViewController
}


class AppDIProvider: ViewControllerFactory {
    
    init() {
        
    }
    
    func createRoomViewController(chatViewModel: ChatViewModel? = nil) -> RoomViewController {
        let viewController: RoomViewController = RoomViewController.create()
        viewController.inject(chatViewModel: DefaultChatViewModel(chatService: DefaultChatService()))
        return viewController
    }
}
