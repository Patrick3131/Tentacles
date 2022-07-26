//
//  File.swift
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
    private var valuePropositionSessionManager: ValuePropositionSessionManager
    private var valuePropositionEvents: AnyCancellable?
    public init() {
        self.valuePropositionSessionManager = ValuePropositionSessionManager()
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
    
    public func removeReporters() {
        analyticsUnit = []
        errorReporters = []
    }
    
    fileprivate func track(_ event: RawAnalyticsEvent) {
        var newEvent = event
        middlewares.forEach { middleware in
            newEvent = middleware.closure(newEvent)
        }
        analyticsUnit.forEach { (reporter, middlewares) in
            var reporterSpecificEvent = newEvent
            middlewares.forEach { middleware in
                reporterSpecificEvent = middleware.closure(reporterSpecificEvent)
            }
            reporter.report(event: newEvent)
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
        if valuePropositionEvents == nil {
            valuePropositionEvents = valuePropositionSessionManager.eventPublisher
                .sink(receiveValue: { [weak self] results in
                    switch results {
                    case .success(let event):
                        self?.track(event)
                    case .failure(let error):
                        self?.track(error)
                    }
                })
        }
        valuePropositionSessionManager.process(for: valueProposition, with: action)
    }
}


