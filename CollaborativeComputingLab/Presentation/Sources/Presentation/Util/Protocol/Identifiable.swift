//
//  Identifiable.swift
//  Presentation
//
//  Created by 김호성 on 2025.11.12.
//

import Foundation

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier : String {
        return String(describing: self)
    }
}
