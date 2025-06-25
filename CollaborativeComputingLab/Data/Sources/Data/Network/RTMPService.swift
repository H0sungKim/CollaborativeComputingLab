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
    private var streamName: String
    
    private var connection: RTMPConnection
    private var stream: RTMPStream
    
    public init(uri: String, streamName: String) {
        self.uri = "rtmp://\(uri)/hls"
        self.streamName = streamName
        
        connection = RTMPConnection()
        stream = RTMPStream(connection: connection)
    }
    
    func publish() async {
        do {
            let connectionResponse = try await connection.connect(uri)
            let publishResponse = try await stream.publish(streamName)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    func play() async {
        do {
            let connectionResponse = try await connection.connect(uri)
            let publishResponse = try await stream.play(streamName)
        } catch {
            NSLog(error.localizedDescription)
        }
    }
    
    func close() async {
        do {
            try await connection.close()
        } catch {
            NSLog(error.localizedDescription)
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
