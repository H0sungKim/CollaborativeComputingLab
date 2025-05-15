//
//  ChatReposiotory.swift
//  Domain
//
//  Created by 김호성 on 2025.04.28.
//

import Foundation
import Combine

public protocol ChatRepository {
    var chatStream: AnyPublisher<ChatEntity, Error> { get }
    
    func sendChat(chatEntity: ChatEntity)
    func connectWebSocket()
    func disconnectWebSocket()
}
