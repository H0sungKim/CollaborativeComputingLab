//
//  main.swift
//  Server
//
//  Created by 김호성 on 2025.06.23.
//

import Foundation

let webSocketServer = try WebSocketServer()
let rtmpServer = RTMPServer()
webSocketServer.start()
rtmpServer.start()
print("Type 'exit' to stop the servers.")
DispatchQueue.global().async {
    while true {
        if let input = readLine()?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
            if input == "exit" {
                print("Exit command received, stopping servers...")
                rtmpServer.stop()
                print("Servers stopped. Exiting program.")
                exit(0)
            } else {
                print("Unknown command: \(input). Type 'exit' to stop.")
            }
        }
    }
}

RunLoop.main.run()
