//
//  File.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

/// Event reported to ``AnalyticsReporter`.
public struct RawAnalyticsEvent {
    /// The name of the event being reported.
    public let name: String
    /// Containing all additional attributes that are reported.
    public var attributes: AttributesValue
}

extension RawAnalyticsEvent {
    init(analyticsEvent: AnalyticsEvent<some TentaclesAttributes>) {
        self.name = analyticsEvent.name
        var attributes = AttributesValue()
        attributes[KeyAttributes.trigger] = analyticsEvent.trigger.name
        attributes[KeyAttributes.category] = analyticsEvent.category.name
        let otherAttributeValues = analyticsEvent.otherAttributes.serialiseToValue()
        for (key, value) in otherAttributeValues {
            attributes[key] = value
        }
        self.attributes = attributes
    }
}
