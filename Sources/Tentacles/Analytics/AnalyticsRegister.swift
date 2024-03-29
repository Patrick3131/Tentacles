//
//  AnalyticsRegister.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Register managing analytics related entities, e.g. ``AnalyticsReporting`` and ``Middleware``s.
public protocol AnalyticsRegister {
    /// Registers reporter to ``AnalyticsRegister`` and its dedicated ``Middleware``s,
    /// ``Middleware``s registered this way only apply to one specifc reporter.
    ///
    /// Register can manage multiple implementations of ``AnalyticsReporting`` with multiple connected ``Middleware``s.
    /// Calling register will add a new reporter and not overwrite previously added reporters.
    func register(_ analyticsReporter: any AnalyticsReporting,
                  with middlewares: [Middleware<RawAnalyticsEvent>])
    /// Registers ``Middleware`` that applies to all events for all reporters registered to ``AnalyticsRegister``.
    func register(_ middleware: Middleware<RawAnalyticsEvent>)
    /// Resets register and its entities.
    ///
    /// - Removes all entities: e.g. ``AnalyticsReporting``s and connected ``Middleware``s.
    /// - Resets identifier of ``Tentacles`` session.
    /// - Resets all ``DomainActivity``sessions.
    /// - Logs out users from connected ``AnalyticsReporting`` entities.
    func reset()
}
