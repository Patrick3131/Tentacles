//
//  ValuePropositionTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Ability to track a ``ValueProposition`` with a ``ValuePropositionAction``.
public protocol ValuePropositionTracking {
    /// Tracks a ``ValueProposition`` with a ``ValuePropositionAction``.
    ///
    /// When a ``ValueProposition`` is tracked, a session is created and managed.
    /// See ``ValueProposition`` documentation for further information.
    func track(_ valueProposition: ValueProposition<some TentaclesAttributes>,
               with action: ValuePropositionAction)
}
