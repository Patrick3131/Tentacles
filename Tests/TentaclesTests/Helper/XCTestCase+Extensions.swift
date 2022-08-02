//
//  File.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Tentacles
import XCTest

extension XCTestCase {
    func buildTentacles(analyticsReporters: [AnalyticsReporter],
                        errorReporters: [NonFatalErrorTracking] = [],
                        commonMiddlewares: [Middleware] = []) -> Tentacles {
        let tentacles = Tentacles()
        analyticsReporters.forEach { tentacles.register(analyticsReporter: $0) }
        errorReporters.forEach { tentacles.register(errorReporter: $0) }
        commonMiddlewares.forEach { tentacles.register($0)}
        return tentacles
    }
    
    func evaluateNumberOfEventsReported(
        _ count: Int,
        for reporterStub: AnalyticsReporterStub) {
            XCTAssertEqual(reporterStub.eventResults.count, count)
        }
    
    func evaluatePreConditionCeroEventsReported(
        reporterStub: AnalyticsReporterStub) {
            XCTAssertEqual(reporterStub.results.count, 0)
        }
}
