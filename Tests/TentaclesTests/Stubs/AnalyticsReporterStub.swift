//
//  AnalyticsReporterStub.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation
@testable import Tentacles
import Combine

class AnalyticsReporterStub: AnalyticsReporting {
    private let _analyticsEventPublisher: PassthroughSubject<Result<RawAnalyticsEvent, Error>, Never> = .init()
    /// Used to test async code
    lazy var analyticsEventPublisher = _analyticsEventPublisher.eraseToAnyPublisher()
    
    private let _idPublisher: PassthroughSubject<String, Never> = .init()
    lazy var idPublisher = _idPublisher.eraseToAnyPublisher()
    
    private let _userAttributesPublisher: PassthroughSubject<AttributesValue, Never> = .init()
    lazy var userAttributesPublisher = _userAttributesPublisher.eraseToAnyPublisher()
    
    private let _logOutPublisher: PassthroughSubject<Void, Never> = .init()
    lazy var logOutPublisher = _logOutPublisher.eraseToAnyPublisher()
    
    private let _setupPublisher: PassthroughSubject<Void, Never> = .init()
    lazy var setupPublisher = _setupPublisher.eraseToAnyPublisher()
    
    func report(_ error: Error, filename: String, line: Int) {
        _analyticsEventPublisher.send(.failure(error))
    }
    
    func identify(with id: String) {
        _idPublisher.send(id)
    }
    
    func logout() {
        _logOutPublisher.send(())
    }
    
    func addUserAttributes(_ attributes: AttributesValue) {
        _userAttributesPublisher.send(attributes)
    }
    
    func setup() {
        _setupPublisher.send(())
    }
    
    func report(_ event: RawAnalyticsEvent) {
        _analyticsEventPublisher.send(.success(event))
    }
}
