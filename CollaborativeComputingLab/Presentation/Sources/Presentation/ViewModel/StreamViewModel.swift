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
import Combine

public protocol StreamViewModelInput {
    func offer()
    func answer()
    func startCaptureLocalVideo(view: UIView)
}

public protocol StreamViewModelOutput {
    var signalingConnection: CurrentValueSubject<Bool, Never> { get }
    var hasLocalSdp: CurrentValueSubject<Bool, Never> { get }
    var hasRemoteSdp: CurrentValueSubject<Bool, Never> { get }
    var webRTCConnection: CurrentValueSubject<IceConnectionState, Never> { get }
}

public protocol StreamViewModel: StreamViewModelInput, StreamViewModelOutput { }

public final class DefaultStreamViewModel: StreamViewModel {
    
    private let streamUseCase: StreamUseCase
    
    public var signalingConnection: CurrentValueSubject<Bool, Never> {
        return streamUseCase.signalingConnection
    }
    
    public var hasLocalSdp: CurrentValueSubject<Bool, Never> {
        return streamUseCase.hasLocalSdp
    }
    
    public var hasRemoteSdp: CurrentValueSubject<Bool, Never> {
        return streamUseCase.hasRemoteSdp
    }
    
    public var webRTCConnection: CurrentValueSubject<Domain.IceConnectionState, Never> {
        return streamUseCase.webRTCConnection
    }
    
    
    public init(streamUseCase: StreamUseCase) {
        self.streamUseCase = streamUseCase
    }
    
    public func offer() {
        streamUseCase.offer()
    }
    
    public func answer() {
        streamUseCase.answer()
    }
    
    public func startCaptureLocalVideo(view: UIView) {
        streamUseCase.startCaptureLocalVideo(view: view)
    }
}
