//
//  AnalyticsEventAction.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Initiator that triggers an ``ValuePropositionAction`` or ``AnalyticsEvent``,
/// a trigger could be i.e. if the user clicks on a button or visits a screen.
///
/// ``TentaclesEventTrigger`` implementation offers default cases.
public protocol AnalyticsEventTrigger {
    var name: String { get }
}
