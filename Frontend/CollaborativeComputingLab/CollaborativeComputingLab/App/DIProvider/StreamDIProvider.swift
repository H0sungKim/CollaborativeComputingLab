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

protocol StreamDIProvider {
    func makeStreamRepository() -> StreamRepository
    func makeStreamRepository(rtmpService: RTMPService) -> StreamRepository
    
    func makeStreamUseCase() -> StreamUseCase
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase
    
    func makeStreamViewModel() -> StreamViewModel
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel
}

class DefaultStreamDIProvider: StreamDIProvider {
    func makeStreamRepository() -> StreamRepository {
        return DefaultStreamRepository(rtmpService: RTMPService(streamName: "test"))
    }
    func makeStreamRepository(rtmpService: RTMPService) -> StreamRepository {
        return DefaultStreamRepository(rtmpService: rtmpService)
    }
    
    func makeStreamUseCase() -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: makeStreamRepository())
    }
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: streamRepository)
    }
    
    func makeStreamViewModel() -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: makeStreamUseCase())
    }
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: streamUseCase)
    }
}
