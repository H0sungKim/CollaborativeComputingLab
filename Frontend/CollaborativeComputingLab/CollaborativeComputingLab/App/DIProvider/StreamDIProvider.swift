//
//  StreamDIProvider.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.05.12.
//

import Domain
import Data
import Presentation

import Foundation

import HaishinKit

protocol StreamDIProvider {
    func makeStreamRepository() -> StreamRepository
    func makeStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository
    
    func makeStreamUseCase() -> StreamUseCase
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase
    
    func makeStreamViewModel() -> StreamViewModel
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel
}

class DefaultStreamDIProvider: @preconcurrency StreamDIProvider {
    @ScreenActor func makeStreamRepository() -> StreamRepository {
        return DefaultStreamRepository(rtmpService: RTMPService(uri: Bundle.main.uri ?? "", streamName: "test"), streamService: StreamService())
    }
    func makeStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository {
        return DefaultStreamRepository(rtmpService: rtmpService, streamService: streamService)
    }
    
    @ScreenActor func makeStreamUseCase() -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: makeStreamRepository())
    }
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: streamRepository)
    }
    
    @ScreenActor func makeStreamViewModel() -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: makeStreamUseCase())
    }
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: streamUseCase)
    }
}
