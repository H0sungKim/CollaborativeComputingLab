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
        connection = RTMPConnection()
        stream = RTMPStream(connection: connection)
        self.streamName = streamName
    }
    
    func publish() async throws {
        let connectionResponse = try await connection.connect(uri)
        print(connectionResponse)
        let publishResponse = try await stream.publish(streamName)
        print(publishResponse)
    }
    
    func play() async throws {
        let connectionResponse = try await connection.connect(uri)
        print(connectionResponse)
        let publishResponse = try await stream.play(streamName)
        print(publishResponse)
    }
    
    func close() async {
        try? await connection.close()
        print("conneciton.close")
    }
    
    func addOutput(_ output: HKStreamOutput) async {
        await stream.addOutput(output)
    }
    
    func addOutputStreamToMixer(mixer: MediaMixer) async {
        await mixer.addOutput(stream)
    }
    
    func attachAudioPlayer(audioPlayer: AudioPlayer) async {
        await stream.attachAudioPlayer(audioPlayer)
    }
}
