//
//  Event.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Event that can be tracked by ``AnalyticsEventTracking``.
public struct AnalyticsEvent<Attributes: TentaclesAttributes> {
    /// Used to categorise ``AnalyticsEvent``, this could be i.e. a life cycle event or an
    /// interaction event.
    ///
    /// Needs to be defined by the app.
    /// ``TentaclesEventCategory`` offers default cases that can be used.
    /// When ``AnalyticsEvent`` is converted to ``RawAnalyticsEvent`` category will be added
    /// as an attribute.
    public var category: AnalyticsEventCategory
    /// Initiator for the event, this could be a click or a appearance of a screen.
    ///
    /// Needs to be defined by the app.
    /// ``TentaclesEventTrigger`` offers default trigger cases that can be used.
    /// When ``AnalyticsEvent`` is converted to ``RawAnalyticsEvent`` trigger will be added
    /// as an attribute.
    public var trigger: AnalyticsEventTrigger
    /// The name of the event being reported
    public var name: String
    /// Additional attributes that are valuable for the event.
    ///
    /// If you want to use no attributes use ``EmptyAttributes``
    public var otherAttributes: Attributes
    
    public init(category: AnalyticsEventCategory, trigger: AnalyticsEventTrigger, name: String, otherAttributes: Attributes) {
        self.category = category
        self.trigger = trigger
        self.name = name
        self.otherAttributes = otherAttributes
    }
}
