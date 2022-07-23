//
//  File.swift
//  
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation


class Tentacles: AnalyticsRegister {
    private var analyticsReporters = [AnalyticsReporter]()
    private var errorReporters = [NonFatalErrorTracking]()
    
    func register(_ reporter: AnalyticsReporter) {
        analyticsReporters.append(reporter)
    }
    
    func register(_ errorReporter: NonFatalErrorTracking) {
        errorReporters.append(errorReporter)
    }
    
    func removeReporters() {
        analyticsReporters = []
        errorReporters = []
    }
    
}

extension Tentacles: AnalyticsEventTracking {
    func track(_ event: AnalyticsEvent) {
        analyticsReporters.forEach { $0.report(event: event) }
    }
}

extension Tentacles: NonFatalErrorTracking {
    func track(_ error: Error) {
        errorReporters.forEach { $0.track(error) }
    }
}

extension Tentacles: ValuePropositionTracking {
    func track(for valueProposition: ValueProposition, with action: ValuePropositionAction) {
        
    }
}


