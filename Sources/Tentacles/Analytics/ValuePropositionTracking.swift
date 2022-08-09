//
//  DomainActivityTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Ability to track a ``DomainActivity`` with a ``DomainActivityAction``.
public protocol DomainActivityTracking {
    /// Tracks a ``DomainActivity`` with a ``DomainActivityAction``.
    ///
    /// When a ``DomainActivity`` is tracked, a session is created and managed.
    /// See ``DomainActivity`` documentation for further information.
    func track(_ domainActivity: DomainActivity<some TentaclesAttributes>,
               with action: DomainActivityAction)
}
