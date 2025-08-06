//
//  JSONManager.swift
//  Data
//
//  Created by 김호성 on 2/13/24.
//

import Foundation

actor JSONManager {
    
    public static let shared = JSONManager()
    
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        
    }
    
    nonisolated func encode<T: Codable>(codable: T) -> Data? {
        do {
            return try encoder.encode(codable)
        } catch {
            Log.e(error.localizedDescription)
        }
        return nil
    }
    
    nonisolated func decode<T: Codable>(data: Data, type: T.Type) -> T? {
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            Log.e(error.localizedDescription)
        }
        return nil
    }
}
