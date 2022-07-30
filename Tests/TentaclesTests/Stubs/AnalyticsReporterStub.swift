//
//  AnalyticsReporterStub.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation
import Tentacles

class AnalyticsReporterStub: AnalyticsReporter {
    var results = [Any]()
    
    func setup() {}
    
    func report(event: RawAnalyticsEvent) {
        results.append(event)
    }
}

extension AnalyticsReporterStub: NonFatalErrorTracking {
    func track(_ error: Error) {
        results.append(error)
    }
}

extension AnalyticsReporterStub {
    func isResultEvent(index: Int) -> RawAnalyticsEvent? {
        results[index] as? RawAnalyticsEvent
    }
    
    func isResultError(index: Int) -> Error? {
        results[index] as? Error
    }
}
