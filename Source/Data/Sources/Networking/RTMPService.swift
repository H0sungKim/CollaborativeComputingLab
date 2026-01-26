//
//  RTMPService.swift
//  Data
//
//  Created by 김호성 on 2025.05.08.
//

import AVFoundation
import Foundation

import HaishinKit
import RTMPHaishinKit

import Domain

public final actor RTMPService {
    
    private var uri: String
    
    private var connection: RTMPConnection
    private var stream: RTMPStream
    
    public init(uri: String) {
        self.uri = "rtmp://\(uri)/hls"
        
        connection = RTMPConnection()
        stream = RTMPStream(connection: connection)
    }
    
    package func publish(streamName: String) async {
        do {
            let connectionResponse = try await connection.connect(uri)
            Log.i(connectionResponse)
            let publishResponse = try await stream.publish(streamName)
            Log.i(publishResponse)
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func play(streamName: String) async {
        do {
            let connectionResponse = try await connection.connect(uri)
            Log.i("\(connectionResponse)")
            let playResponse = try await stream.play(streamName)
            Log.i("\(playResponse)")
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func close() async {
        do {
            try await connection.close()
        } catch {
            Log.e(error.localizedDescription)
        }
    }
    
    package func addOutput(_ output: StreamOutput) async {
        await stream.addOutput(output)
    }
    
    package func attachAudioPlayer(audioPlayer: AudioPlayer) async {
        await stream.attachAudioPlayer(audioPlayer)
    }
    
    package func getStream() -> RTMPStream {
        return stream
    }
}
