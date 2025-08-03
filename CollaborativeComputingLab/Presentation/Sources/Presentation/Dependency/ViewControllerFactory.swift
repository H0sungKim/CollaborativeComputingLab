//
//  ViewControllerFactory.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import UIKit

public protocol ViewControllerFactory {
    func createHomeViewController(roomViewModel: RoomViewModel?) -> HomeViewController
    func createRoomViewController(id: String, userName: String, role: RoomRole, roomViewModel: RoomViewModel?, chatViewModel: ChatViewModel?, streamViewModel: StreamViewModel?) -> RoomViewController
}
