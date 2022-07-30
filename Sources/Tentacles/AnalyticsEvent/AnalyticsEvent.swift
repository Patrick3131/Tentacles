//
//  Event.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Basic event that is used for tracking
public protocol AnalyticsEvent {
    associatedtype Attributes: TentacleAttributes
    var category: AnalyticsEventCategory { get }
    /// Initiator for the event, this could be a click or a appearance of a screen.
    /// Needs to be defined by the app.
    /// TentaclesEventTrigger offers default trigger cases, that can be used.
    var trigger: AnalyticsEventTrigger { get }
    var name: String { get }
    /// additional attributes that are valuebale for the event.
    var otherAttributes: Attributes? { get }
}
