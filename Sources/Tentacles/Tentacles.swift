//
//  Tentacles.swift
//  
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation
import Combine

public class Tentacles: AnalyticsRegister {
    private typealias AnalyticsUnit = (reporter: AnalyticsReporter, middlewares: [Middleware])
    private var analyticsUnit = [AnalyticsUnit]()
    private var errorReporters = [NonFatalErrorTracking]()
    private var middlewares = [Middleware]()
    private var valuePropositionSessionManager: ValuePropositionSessionManager?
    private var valuePropositionEvents: AnyCancellable?
    
    public init() {
        
    }
    
    public func register(_ middleware: Middleware) {
        middlewares.append(middleware)
    }
    
    public func register(analyticsReporter: AnalyticsReporter, middlewares: [Middleware] = []) {
        let analyticsUnit: AnalyticsUnit = (reporter: analyticsReporter, middlewares: middlewares)
        self.analyticsUnit.append(analyticsUnit)
    }
    
    public func register(errorReporter: NonFatalErrorTracking) {
        errorReporters.append(errorReporter)
    }
    
    public func resetRegister() {
        analyticsUnit = []
        errorReporters = []
    }
    
    fileprivate func track(_ event: RawAnalyticsEvent) {
        var newEvent: RawAnalyticsEvent? = event
        middlewares.forEach { middleware in
            newEvent = middleware.closure(event)
        }
        analyticsUnit.forEach { (reporter, middlewares) in
            middlewares.forEach { middleware in
                if let unwrappedEvent = newEvent {
                    newEvent = middleware.closure(unwrappedEvent)
                }
            }
            if let newEvent {
                reporter.report(event: newEvent)
            }
        }
    }
}

extension Tentacles: AnalyticsEventTracking {
    public func track(_ event: any AnalyticsEvent) {
       track(RawAnalyticsEvent(analyticsEvent: event))
    }
}

extension Tentacles: NonFatalErrorTracking {
    public func track(_ error: Error) {
        errorReporters.forEach { $0.track(error) }
    }
}

extension Tentacles: ValuePropositionTracking {
    public func track(for valueProposition: any ValueProposition, with action: ValuePropositionAction) {
        if valuePropositionSessionManager == nil,
           valuePropositionEvents == nil {
            valuePropositionSessionManager = .init()
            valuePropositionEvents = valuePropositionSessionManager?
                .eventPublisher
                .sink(receiveValue: { [weak self] results in
                    switch results {
                    case .success(let event):
                        self?.track(event)
                    case .failure(let error):
                        self?.track(error)
                    }
                })
        }
        valuePropositionSessionManager?.process(for: valueProposition, with: action)
    }
}


