//
//  PFTracking.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

protocol UserIdentifyingTracking {
    /// Identifies a user for tracking.
    /// - Parameters:
    ///     -   id: The user id associated to the user.
    func identify(with id: String)
    /// Resets the identity of a user.
    func reset()
}

public protocol AnalyticsEventTracking {
    func track(_ event: any AnalyticsEvent)
}

public protocol ValuePropositionTracking {
    func track(for valueProposition: any ValueProposition,
               with action: ValuePropositionAction)
}

public protocol NonFatalErrorTracking {
    func track(_ error: Error)
}

public protocol AnalyticsReporter {
    func setup()
    func report(event: RawAnalyticsEvent)
}

public protocol AnalyticsRegister {
    /// Registers middleware that applies to all events for all reporters registered to AnalyticsRegister
    func register(_ middleware: Middleware)
    /// Registers reporter to AnalyticsRegister and its specific middlewares, middlewares registered this way
    /// only apply to one specific reporter.
    func register(_ reporter: AnalyticsReporter, middlewares: [Middleware])
    func register(_ errorReporter: NonFatalErrorTracking)
    /// removes all reporters, both AnalyticsReporter and NonFatalTrackingReporter, and its specific middlewares
    func removeReporters()
}

