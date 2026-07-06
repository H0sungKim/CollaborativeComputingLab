//
//  WebSocketServer.swift
//  Server
//
//  Created by 김호성 on 2025.06.24.
//

import Foundation
import FoundationModels
import Network
import Speech

import DTO
import Entity

final class WebSocketServer {
    
    private let queue = DispatchQueue.global()
    private let port: NWEndpoint.Port = 8080
    private let listener: NWListener
    private var connectedClients = Set<WebSocketClient>()
    private var chatRooms: [String: Room] = [:]
    
    init() throws {
        let parameters = NWParameters.tcp
        let webSocketOptions = NWProtocolWebSocket.Options()
        webSocketOptions.autoReplyPing = true
        parameters.defaultProtocolStack.applicationProtocols.append(webSocketOptions)
        listener = try NWListener(using: parameters, on: port)
    }
    
    func start() {
        Log.i(listener.debugDescription)
        listener.newConnectionHandler = newConnectionHandler
        listener.start(queue: queue)
        Log.i("Server started listening on port \(port)")
    }
    
    private func newConnectionHandler(_ connection: NWConnection) {
        let client = WebSocketClient(connection: connection)
        connectedClients.insert(client)
        client.connection.start(queue: queue)
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
        let roomEntityList: [RoomEntity] = chatRooms.values.map(\.roomEntity)
        if let encoded = ServerMessage.availableRooms(RoomListDTO(entities: roomEntityList)).encode() {
            broadcast(data: encoded, to: [client])
        }
        Log.i("A client has connected. Total connected clients: \(connectedClients.count)")
    }
    
    private func didDisconnect(client: WebSocketClient) {
        chatRooms.values.forEach({ room in
            if room.removeClient(client) {
                if !room.isAvailable {
                    closeRoom(id: room.id)
                    chatRooms.removeValue(forKey: room.id)
                } else {
                    broadcastParticipants(id: room.id)
                }
                broadcastAvailableRooms(to: connectedClients)
            }
        })
        Log.i("A client has disconnected. Total connected clients: \(connectedClients.count)")
    }
    
    private func didReceiveMessage(from client: WebSocketClient,
                                   data: Data?,
                                   context: NWConnection.ContentContext?,
                                   error: NWError?) {
        
        if let context = context, context.isFinal {
            client.connection.cancel()
            didDisconnect(client: client)
            return
        }
        
        client.connection.receiveMessage { [weak self] (data, context, isComplete, error) in
            self?.didReceiveMessage(from: client, data: data, context: context, error: error)
        }
        
        guard let data, let message = data.decode(type: ClientMessage.self) else { return }
        
        switch message {
        case .requestRoomList:
            Log.i("Received request for room list.")
            broadcastAvailableRooms(to: [client])
        case .enterRoom(let roomEntranceDTO):
            let entity = roomEntranceDTO.entity
            Log.i(entity)
            client.name = entity.userName
            let room: Room = {
                guard let room = chatRooms[entity.id] else {
                    chatRooms[entity.id] = Room(id: entity.id, instructor: client)
                    return chatRooms[entity.id]!
                }
                return room
            }()
            room.addClient(client)
            
            broadcastAvailableRooms(to: connectedClients)
            broadcastParticipants(id: entity.id)
        case .leaveRoom(let roomExitDTO):
            let entity = roomExitDTO.entity
            Log.i(entity)
            chatRooms[entity.id]?.removeClient(client)
            
            if !(chatRooms[entity.id]?.isAvailable ?? false) {
                closeRoom(id: entity.id)
                chatRooms.removeValue(forKey: entity.id)
            } else {
                broadcastParticipants(id: entity.id)
            }
            
            broadcastAvailableRooms(to: connectedClients)
        case .sendChat(let messageDTO):
            let entity = messageDTO.entity
            Log.i(entity)
            broadcastMessage(message: entity, sender: client)
        }
    }
    
    private func broadcast(data: Data, to clients: Set<WebSocketClient>) {
        clients.forEach {
            let metadata = NWProtocolWebSocket.Metadata(opcode: .binary)
            let context = NWConnection.ContentContext(identifier: "context", metadata: [metadata])

            $0.connection.send(
                content: data,
                contentContext: context,
                isComplete: true,
                completion: .contentProcessed({ _ in })
            )
        }
    }
    
    private func broadcastAvailableRooms(to clients: Set<WebSocketClient>) {
        let message = ServerMessage.availableRooms(getRoomListDTO())
        Log.i(message)
        guard let messageData = message.encode() else { return }
        broadcast(data: messageData, to: clients)
    }
    
    private func getRoomListDTO() -> RoomListDTO {
        return RoomListDTO(rooms: chatRooms.map({ (id, room) in
            RoomListDTO.RoomDTO(id: id, participants: room.clients.compactMap(\.name))
        }))
    }
    
    private func broadcastParticipants(id: String) {
        let message = ServerMessage.participantUpdated(getParticipantListDTO(id: id))
        Log.i(message)
        guard let messageData = message.encode() else { return }
        broadcast(data: messageData, to: Set(chatRooms[id]?.clients ?? []))
    }
    
    private func getParticipantListDTO(id: String) -> ParticipantListDTO {
        return ParticipantListDTO(participants: chatRooms[id]?.clients.compactMap({ ParticipantListDTO.ParticipantDTO(name: $0.name) }))
    }
    
    private func closeRoom(id: String) {
        let message = ServerMessage.roomClosed
        Log.i(message)
        guard let messageData = message.encode() else { return }
        broadcast(data: messageData, to: Set(chatRooms[id]?.clients ?? []))
        DispatchQueue.global().async {
            sleep(5)
            do {
                try self.processRecording(roomID: id)
            } catch {
                Log.e(error)
            }
        }
    }
    
    private func processRecording(roomID: String) throws {

        let root = URL(
            fileURLWithPath:
            "/Users/hosungkim/Source/CollaborativeComputingLab"
        )

        let flvURL = root
            .appending(path: "recordings")
            .appending(path: "\(roomID).flv")

        //
        // output mp4
        //

        let videosDirectory = root
            .appending(path: "videos")

        try FileManager.default.createDirectory(
            at: videosDirectory,
            withIntermediateDirectories: true
        )

        let mp4URL = videosDirectory
            .appending(path: "\(roomID).mp4")
        
        let audiosDirectory = root.appending(path: "audios")

        try FileManager.default.createDirectory(
            at: audiosDirectory,
            withIntermediateDirectories: true
        )
        
        let m4aURL = audiosDirectory.appending(path: "\(roomID).m4a")
        
        //
        // vod directory
        //

        let vodDirectory = root
            .appending(path: "vod")
            .appending(path: roomID)

        try FileManager.default.createDirectory(
            at: vodDirectory,
            withIntermediateDirectories: true
        )

        //
        // flv -> mp4
        //

        try convertToMP4(
            input: flvURL,
            output: mp4URL
        )
        
        try extractAudio(input: mp4URL, output: m4aURL)
        
        Task {
            let transcript = try await transcribe(url: m4aURL)
            Log.d(transcript)
            try saveTranscript(text: transcript, roomID: roomID)
            let response = try await summarize(transcript: transcript, roomId: roomID)
            Log.d(response)
            
        }

        //
        // mp4 -> vod hls
        //

        let m3u8URL = vodDirectory
            .appending(path: "index.m3u8")

        try createVODHLS(
            input: mp4URL,
            output: m3u8URL
        )

        Log.i("VOD generated: \(m3u8URL)")
    }
    
    private func convertToMP4(
        input: URL,
        output: URL
    ) throws {

        let process = Process()

        process.executableURL = URL(
            fileURLWithPath: "/opt/homebrew/bin/ffmpeg"
        )

        process.arguments = [
            "-i",
            input.path(),
            "-c",
            "copy",
            output.path()
        ]

        try process.run()

        process.waitUntilExit()
    }
    
    private func createVODHLS(
        input: URL,
        output: URL
    ) throws {

        let process = Process()

        process.executableURL = URL(
            fileURLWithPath: "/opt/homebrew/bin/ffmpeg"
        )

        process.arguments = [
            "-i",
            input.path(),
            "-codec",
            "copy",
            "-start_number",
            "0",
            "-hls_time",
            "6",
            "-hls_list_size",
            "0",
            "-f",
            "hls",
            output.path()
        ]

        try process.run()

        process.waitUntilExit()
    }
    
    func extractAudio(
        input: URL,
        output: URL
    ) throws {

        let process = Process()

        process.executableURL = URL(
            fileURLWithPath: "/opt/homebrew/bin/ffmpeg"
        )

        process.arguments = [
            "-i",
            input.path(),
            "-vn",
            "-acodec",
            "aac",
            output.path()
        ]

        try process.run()

        process.waitUntilExit()
    }
    
    private func transcribe(url: URL) async throws -> String {

        guard let recognizer = SFSpeechRecognizer(
            locale: Locale(identifier: "ko-KR")
        ) else {
            throw NSError(domain: "Speech", code: -1)
        }

        let request = SFSpeechURLRecognitionRequest(url: url)

        request.shouldReportPartialResults = true

        return try await withCheckedThrowingContinuation { continuation in

            var resumed = false
            var latestText = ""

            let task = recognizer.recognitionTask(with: request) {
                result,
                error in

                if let result {
                    latestText = result.bestTranscription.formattedString

                    Log.d("""
                    partial:
                    \(latestText)
                    """)
                }

                if let error, !resumed {
                    resumed = true
                    continuation.resume(throwing: error)
                    return
                }

                if let result, result.isFinal, !resumed {
                    resumed = true
                    continuation.resume(returning: latestText)
                }
            }

            _ = task
        }
    }
    
    private func summarize(transcript: String, roomId: String) async throws -> String {
        let session = LanguageModelSession(
            instructions: """
            You are an AI assistant that summarizes lecture transcripts.

            Your task:
            - Summarize the lecture clearly and accurately.
            - Focus on important concepts, definitions, explanations, and conclusions.
            - Remove filler words, repeated sentences, casual conversation, and unnecessary speech.
            - Preserve technical terms exactly as spoken.
            - Do not invent information that was not mentioned in the lecture.
            - Organize the summary into sections with concise bullet points.
            - If the lecture explains a process or sequence, preserve the order.
            - If examples are important for understanding, briefly include them.
            - Keep the summary dense and informative.

            Language rules:
            - Detect the primary language of the lecture transcript.
            - Write the summary in the same language as the lecture.
            - Preserve technical terms, APIs, framework names, and code identifiers in their original form.
            - If multiple languages are mixed, use the dominant language of the lecture.

            Transcript handling:
            - The transcript may contain speech recognition errors.
            - Infer the intended meaning carefully from context.

            Use concise and professional language.
            """
        )
        
        
        let response = try await session.respond(
            to: """
            Please summarize the following lecture transcript.

            Transcript:
            \(transcript)
            """
        )
        return response.content
    }
    
    private func saveTranscript(
        text: String,
        roomID: String
    ) throws {

        let root = URL(
            fileURLWithPath:
            "/Users/hosungkim/Source/CollaborativeComputingLab"
        )

        let directory = root
            .appending(path: "subtitles")
            .appending(path: roomID)

        try FileManager.default.createDirectory(
            at: directory,
            withIntermediateDirectories: true
        )

        let fileURL = directory.appending(path: "transcript.txt")

        try text.write(
            to: fileURL,
            atomically: true,
            encoding: .utf8
        )
    }
    
    private func broadcastMessage(message: MessageEntity, sender: WebSocketClient) {
        let message = ServerMessage.newChat(ChatDTO(name: sender.name, message: message.message))
        Log.i(message)
        guard let messageData = message.encode() else { return }
        chatRooms.values.forEach({ room in
            if room.clients.contains(sender) {
                broadcast(data: messageData, to: Set(room.clients))
            }
        })
    }
}
