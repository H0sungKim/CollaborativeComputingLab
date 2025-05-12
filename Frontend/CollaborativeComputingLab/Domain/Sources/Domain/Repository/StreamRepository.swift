//
//  File.swift
//  Domain
//
//  Created by 김호성 on 2025.05.10.
//

import Foundation
import UIKit

public protocol StreamRepository: Sendable {
    func open(method: StreamRole) async
    func close() async
    func addOutputView(_ view: UIView) async
    func addOutputStreamToMixer(mixer: Any) async
}
