//
//  File.swift
//  Data
//
//  Created by 김호성 on 2025.05.08.
//

import Domain

import Foundation
import AVFoundation
import Foundation
import HaishinKit

public final actor RTMPService {
    static let maxRetryCount: Int = 5
    
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
    
    func open(method: StreamRole) async {
        do {
            let response = try await connection.connect(uri)
            print(response)
            switch method {
            case .publish:
                let response = try await stream.publish(streamName)
                print(response)
            case .play:
                let response = try await stream.play(streamName)
                print(response)
            }
        } catch RTMPConnection.Error.requestFailed(let response) {
            print(response)
        } catch RTMPStream.Error.requestFailed(let response) {
            print(response)
        } catch {
            print(error)
        }
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
