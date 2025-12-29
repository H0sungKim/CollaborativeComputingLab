//
//  ChatReposiotory.swift
//  Domain
//
//  Created by 김호성 on 2025.04.28.
//

import Foundation
import Combine

import Entity

public protocol ChatRepository {
    var chatStream: AnyPublisher<ChatEntity, Never> { get }
    
    func sendChat(messageEntity: MessageEntity)
    func connectWebSocket()
}
