//
//  StreamDIProvider.swift
//  CollaborativeComputingLab
//
//  Created by 김호성 on 2025.05.12.
//

import Data
import Domain
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
