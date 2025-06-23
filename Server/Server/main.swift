//
//  main.swift
//  Server
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation

let server = try WebSocketServer()
server.start()
RunLoop.main.run()
