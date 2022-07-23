//
//  File.swift
//  
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation


public class Tentacles: AnalyticsRegister {
    private var analyticsReporters = [AnalyticsReporter]()
    private var errorReporters = [NonFatalErrorTracking]()
    private var middlewares = [Middleware]()
    private var valuePropositionSessionManager: ValuePropositionSessionManager
    public init() {
        self.middlewares.append(ValuePropositionSessionMiddleware())
        self.valuePropositionSessionManager = ValuePropositionSessionManager()
    }
    
    public func register(_ reporter: AnalyticsReporter) {
        analyticsReporters.append(reporter)
    }
    
    public func register(_ errorReporter: NonFatalErrorTracking) {
        errorReporters.append(errorReporter)
    }
    
    public func removeReporters() {
        analyticsReporters = []
        errorReporters = []
    }
    
}

extension Tentacles: AnalyticsEventTracking {
    public func track(_ event: any AnalyticsEvent) {
        var rawAnalyticsEvent = RawAnalyticsEvent(analyticsEvent: event)
        middlewares.forEach { middleware in
            rawAnalyticsEvent = middleware.transform(rawAnalyticsEvent)
        }
        analyticsReporters.forEach { $0.report(event: rawAnalyticsEvent) }
    }
}

extension Tentacles: NonFatalErrorTracking {
    public func track(_ error: Error) {
        errorReporters.forEach { $0.track(error) }
    }
}

extension Tentacles: ValuePropositionTracking {
    public func track(for valueProposition: any ValueProposition, with action: ValuePropositionAction) {
        do {
            let event = try valuePropositionSessionManager.process(for: valueProposition, with: action)
            self.track(event)
        } catch {
            self.track(error)
        }
    }
}


