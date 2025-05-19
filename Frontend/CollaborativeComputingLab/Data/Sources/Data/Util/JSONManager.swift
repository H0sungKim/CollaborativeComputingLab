//
//  JSONManager.swift
//  Data
//
//  Created by 김호성 on 2/13/24.
//

import Domain

import Foundation

actor JSONManager {
    
    public static let shared = JSONManager()
    
    private init() {
        
    }
    
    nonisolated func encode<T: Codable>(codable: T) throws -> String {
        guard let encoded = try? JSONEncoder().encode(codable) else {
            throw CCLError.encodeFailed(string: "\(codable)")
        }
        return String(decoding: encoded, as: UTF8.self)
    }
    
    nonisolated func decode<T: Codable>(string: String, type: T.Type) throws -> T {
        guard let data = string.data(using: .utf8) else {
            throw CCLError.dataFailed(string: string)
        }
        guard let decoded = try? JSONDecoder().decode(T.self, from: data) else {
            throw CCLError.decodeFailed(string: string)
        }
        return decoded
    }
}
