//
//  Event.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Basic event that is used for tracking
public protocol AnalyticsEvent {
    /// Initiator for the event, this could be a click or a appearance of a screen.
    /// Needs to be defined by the app.
    var trigger: AnalyticsEventTrigger { get }
    var category: AnalyticsEventCategory { get }
    var name: String { get }
    /// additional attributes that are valuebale for the event.
    var otherAttributes: PFAttributes { get }
}

