//
//  File.swift
//  Presentation
//
//  Created by 김호성 on 2025.04.27.
//

import Foundation
import UIKit

public protocol ViewControllerFactory {
    func createHomeViewController() -> HomeViewController
    func createRoomViewController(id: String, role: RoomRole, chatViewModel: ChatViewModel?, streamViewModel: StreamViewModel?) -> RoomViewController
}
