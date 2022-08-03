//
//  Event.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Event that can be tracked by ``AnalyticsEventReporting``.
public protocol AnalyticsEvent {
    associatedtype Attributes: TentaclesAttributes
    /// Used to categorise ``AnalyticsEvent``, this could be i.e. a life cycle event or an
    /// interaction event.
    ///
    /// Needs to be defined by the app.
    /// ``TentaclesEventCategory`` offers default cases that can be used.
    /// When ``AnalyticsEvent`` is converted to ``RawAnalyticsEvent`` category will be added
    /// as an attribute.
    var category: AnalyticsEventCategory { get }
    /// Initiator for the event, this could be a click or a appearance of a screen.
    ///
    /// Needs to be defined by the app.
    /// ``TentaclesEventTrigger`` offers default trigger cases that can be used.
    /// When ``AnalyticsEvent`` is converted to ``RawAnalyticsEvent`` trigger will be added
    /// as an attribute.
    var trigger: AnalyticsEventTrigger { get }
    /// The name of the event being reported
    var name: String { get }
    /// Additional attributes that are valuable for the event.
    var otherAttributes: Attributes? { get }
}
