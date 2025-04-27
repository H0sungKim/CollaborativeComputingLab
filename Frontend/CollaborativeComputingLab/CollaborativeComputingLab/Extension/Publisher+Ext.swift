//
//  Publisher+Ext.swift
//  PresentationLayer
//
//  Created by 김호성 on 2025.03.03.
//

import Foundation
import Combine

extension Publisher {
    func sinkHandledCompletion(receiveValue: @escaping ((Self.Output) -> Void)) -> AnyCancellable {
        return self.sink(receiveCompletion: handleCompletion, receiveValue: receiveValue)
    }
    
    private func handleCompletion(completion: Subscribers.Completion<Self.Failure>) {
        switch completion {
        case .finished: break
        case .failure(let error):
            NSLog(error.localizedDescription)
        }
    }
    
    func manageThread() -> AnyPublisher<Output, Failure> {
        return self
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
