//
//  RTMPServer.swift
//  Server
//
//  Created by 김호성 on 2025.06.24.
//

import Foundation

final class RTMPServer {
    
    func start() {
        let process = Process()
        let sourceRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
        let nginxPath = sourceRoot
            .appendingPathComponent("nginx")
            .appendingPathComponent("nginx")
            .path
        
        let nginxConfPath = sourceRoot
            .appendingPathComponent("nginx")
            .appendingPathComponent("nginx.conf")
            .path
        
        process.executableURL = URL(fileURLWithPath: nginxPath)
        process.arguments = ["-c", nginxConfPath]
        do {
            try process.run()
            print("RTMP server started successfully.")
        } catch {
            print("Failed to start RTMP server: \(error.localizedDescription)")
        }
        
    }
    
    func stop() {
        let process = Process()
        let sourceRoot = URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
        let nginxPath = sourceRoot
            .appendingPathComponent("nginx")
            .appendingPathComponent("nginx")
            .path
        
        process.executableURL = URL(fileURLWithPath: nginxPath)
        process.arguments = ["-s", "stop"]
        
        do {
            try process.run()
            print("RTMP server stopped successfully.")
        } catch {
            print("Failed to stop RTMP server: \(error.localizedDescription)")
        }
        
        process.waitUntilExit()
    }
}
