//
//  AnalyticsRegister.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Register managing analytics related entities, e.g. AnalyticsReporter and Middlewares
public protocol AnalyticsRegister {
    /// Registers reporter to AnalyticsRegister and its specific middlewares, middlewares registered this way
    /// only apply to one specific reporter.
    ///
    /// Register can manage multiple AnalyticsReporter with multiple connected
    /// Middlewares. Calling register will add a new reporter and not overwrite previously added reporters.
    func register(analyticsReporter: any AnalyticsReporting, middlewares: [Middleware<RawAnalyticsEvent>])
    /// Registers middleware that applies to all events for all reporters registered to AnalyticsRegister
    func register(_ middleware: Middleware<RawAnalyticsEvent>)
    /// Removes all entities: e.g. AnalyticsReporters and connected Middlewares
    func resetRegister()
}
