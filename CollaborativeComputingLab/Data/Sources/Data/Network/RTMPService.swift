//
//  RTMPService.swift
//  Data
//
//  Created by 김호성 on 2025.05.08.
//

import Domain

import Foundation
import AVFoundation

import HaishinKit

public final actor RTMPService {
    
    private var uri: String
    
    private var connection: RTMPConnection
    private var stream: RTMPStream
    
    public init(uri: String) {
        self.uri = "rtmp://\(uri)/hls"
        
        connection = RTMPConnection()
        stream = RTMPStream(connection: connection)
    }
    
    func publish(streamName: String) async {
        do {
            let connectionResponse = try await connection.connect(uri)
            Logger.log(connectionResponse)
            let publishResponse = try await stream.publish(streamName)
            Logger.log(publishResponse)
        } catch {
            Logger.log(error.localizedDescription, level: .error)
        }
    }
    
    func play(streamName: String) async {
        do {
            let connectionResponse = try await connection.connect(uri)
            Logger.log("\(connectionResponse)")
            let playResponse = try await stream.play(streamName)
            Logger.log("\(playResponse)")
        } catch {
            Logger.log(error.localizedDescription, level: .error)
        }
    }
    
    func close() async {
        do {
            try await connection.close()
        } catch {
            Logger.log(error.localizedDescription, level: .error)
        }
    }
    
    func addOutput(_ output: HKStreamOutput) async {
        await stream.addOutput(output)
    }
    
    func attachAudioPlayer(audioPlayer: AudioPlayer) async {
        await stream.attachAudioPlayer(audioPlayer)
    }
    
    func getStream() -> RTMPStream {
        return stream
    }
}
