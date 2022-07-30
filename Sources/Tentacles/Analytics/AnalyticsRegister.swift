//
//  AnalyticsRegister.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol AnalyticsRegister {
    /// Registers reporter to AnalyticsRegister and its specific middlewares, middlewares registered this way
    /// only apply to one specific reporter.
    func register(analyticsReporter: AnalyticsReporter, middlewares: [Middleware])
    func register(errorReporter: NonFatalErrorTracking)
    /// Registers middleware that applies to all events for all reporters registered to AnalyticsRegister
    func register(_ middleware: Middleware)
    /// Removes all entities, AnalyticsReporters, NonFatalTrackingReporters and connected middlewares
    func resetRegister()
}
