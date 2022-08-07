//
//  AnalyticsEventTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Ability to track an AnalyticsEvent.
public protocol AnalyticsEventTracking {
    /// Tracks an ``AnalyticsEvent``.
    ///
    /// When tracking the ``AnalyticsEvent`` it is converted to a ``RawAnalyticsEvent``
    /// and forwarded to a reporter.
    func track(_ event: AnalyticsEvent<some TentaclesAttributes>)
}
