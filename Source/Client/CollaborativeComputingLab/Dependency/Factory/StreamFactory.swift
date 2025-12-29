//
//  StreamFactory.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.05.12.
//

import Foundation

import HaishinKit

import Data
import Domain
import Presentation

protocol StreamFactory {
    func buildStreamRepository() -> StreamRepository
    func buildStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository
    
    func buildStreamUseCase() -> StreamUseCase
    func buildStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase
    
    func buildStreamViewModel() -> StreamViewModel
    func buildStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel
}

extension StreamFactory {
    func buildStreamRepository(rtmpService: RTMPService, streamService: StreamService) -> StreamRepository {
        return DefaultStreamRepository(rtmpService: rtmpService, streamService: streamService)
    }
    
    func buildStreamUseCase() -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: buildStreamRepository())
    }
    func buildStreamUseCase(streamRepository: StreamRepository) -> StreamUseCase {
        return DefaultStreamUseCase(streamRepository: streamRepository)
    }
    
    func buildStreamViewModel() -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: buildStreamUseCase())
    }
    func buildStreamViewModel(streamUseCase: StreamUseCase) -> StreamViewModel {
        return DefaultStreamViewModel(streamUseCase: streamUseCase)
    }
}
