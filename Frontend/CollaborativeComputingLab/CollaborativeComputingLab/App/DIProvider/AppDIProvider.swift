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
    
    init() {
        self.meetingRoomDIProvider = DefaultMeetingRoomDIProvider()
    }
    
    init(meetingRoomDIProvider: MeetingRoomDIProvider) {
        self.meetingRoomDIProvider = meetingRoomDIProvider
    }
    
    private let meetingRoomDIProvider: MeetingRoomDIProvider
    
    func createMeetingRoomViewController() -> MeetingRoomViewController {
        let viewController: MeetingRoomViewController = MeetingRoomViewController.create()
        return viewController
    }
}
