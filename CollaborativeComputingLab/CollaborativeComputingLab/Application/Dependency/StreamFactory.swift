//
//  StreamFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.05.12.
//

import Data
import Domain
import Presentation

import Foundation

import HaishinKit

protocol StreamFactory {
    func makeRTMPService() -> RTMPService
    func makeStreamService() -> StreamService
    
    func makeStreamRepository() -> StreamRepository
    func makeStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository
    
    func makeStreamUseCase() -> StreamUseCase
    func makeStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase
    
    func makeStreamViewModel() -> StreamViewModel
    func makeStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel
}

extension StreamFactory {
    func makeStreamRepository() -> StreamRepository {
        return DefaultStreamRepository(rtmpService: makeRTMPService(), streamService: makeStreamService())
    }
    func makeStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository {
        return DefaultStreamRepository(rtmpService: rtmpService, streamService: streamService)
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
