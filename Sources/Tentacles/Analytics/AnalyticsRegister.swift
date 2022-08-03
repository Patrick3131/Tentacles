//
//  AnalyticsRegister.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Register managing analytics related entities, e.g. ``AnalyticsReporting`` and ``Middleware`s.
public protocol AnalyticsRegister {
    /// Registers reporter to ``AnalyticsRegister`` and its specific ``Middleware``s, middlewares registered this way
    /// only apply to one specific reporter.
    ///
    /// Register can manage multiple implementations of ``AnalyticsReporting`` with multiple connected ``Middleware``s.
    /// Calling register will add a new reporter and not overwrite previously added reporters.
    func register(analyticsReporter: any AnalyticsReporting,
                  middlewares: [Middleware<RawAnalyticsEvent>])
    /// Registers ``Middleware`` that applies to all events for all reporters registered to ``AnalyticsRegister``.
    func register(_ middleware: Middleware<RawAnalyticsEvent>)
    /// Removes all entities: e.g. ``AnalyticsReporting``s and connected ``Middleware``s.
    func resetRegister()
}
