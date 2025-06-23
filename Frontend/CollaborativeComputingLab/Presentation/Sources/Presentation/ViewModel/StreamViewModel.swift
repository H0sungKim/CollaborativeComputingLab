//
//  StreamViewModel.swift
//  Presentation
//
//  Created by 김호성 on 2025.05.11.
//

import Domain

import UIKit
import Foundation
import AVFoundation
import ReplayKit

public protocol StreamViewModelInput {
    func offer()
    func answer()
}

public protocol StreamViewModelOutput {
    
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput { }

public final class DefaultStreamViewModel: StreamViewModel {
    
    private let streamUseCase: StreamUseCase
    
    public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func offer() {
        streamUseCase.offer()
    }
    
    public func answer() {
        streamUseCase.answer()
    }
    
    
}
