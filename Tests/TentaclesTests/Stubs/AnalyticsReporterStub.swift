//
//  AnalyticsReporterStub.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation
import Tentacles
import Combine

class AnalyticsReporterStub: AnalyticsReporting {
    func report(_ error: Error, filename: String, line: Int) {
        results.append(.failure(error))
        _resultPublisher.send(.failure(error))
    }
    
    func identify(with id: String) {}
    
    func logout() {}
    
    func addUserAttributes(_ attributes: AttributesValue) {}
    
    /// Used to test sync code
    var results = [Result<RawAnalyticsEvent, Error>]()
    /// Used to test sync code
    var errorResults: [Error] {
        results.compactMap { result in
            switch result {
            case .success: return nil
            case .failure(let error): return error
            }
        }
    }
    /// Used to test sync code
    var eventResults: [RawAnalyticsEvent] {
        results.compactMap { result in
            switch result {
            case .success(let event): return event
            case .failure: return nil
            }
        }
     }
    private let _resultPublisher: PassthroughSubject<Result<RawAnalyticsEvent, Error>, Never> = .init()
    /// Used to test async code
    lazy var resultPublisher = _resultPublisher.eraseToAnyPublisher()
    
    func setup() {}
    
    func report(event: RawAnalyticsEvent) {
        results.append(.success(event))
        _resultPublisher.send(.success(event))
    }
}

extension AnalyticsReporterStub {
    func isResultEvent(index: Int) -> RawAnalyticsEvent? {
        let result = results[index]
        switch result {
        case .success(let event):
            return event
        case .failure: return nil
        }
    }
    
    func isResultError(index: Int) -> Error? {
        let result = results[index]
        switch result {
        case .success: return nil
        case .failure(let error):
            return error
        }
    }
}
