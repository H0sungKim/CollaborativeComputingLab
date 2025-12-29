//
//  ViewControllerFactory.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import ViewModel

import UIKit

public protocol ViewControllerFactory {
    func buildHomeViewController(roomViewModel: RoomViewModel?) -> HomeViewController
    func buildRoomViewController(id: String, userName: String, role: RoomRole, roomViewModel: RoomViewModel?, chatViewModel: ChatViewModel?, streamViewModel: StreamViewModel?) -> RoomViewController
}
