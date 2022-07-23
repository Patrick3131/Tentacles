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
    func register(_ reporter: AnalyticsReporter)
    func register(_ errorReporter: NonFatalErrorTracking)
    func removeReporters()
}

