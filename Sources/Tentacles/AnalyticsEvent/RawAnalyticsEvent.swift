//
//  File.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

/// Event reported to AnalyticsReporter
public struct RawAnalyticsEvent {
    /// The name of the event being reported.
    public let name: String
    /// Containing all additional attributes that are reported.
    public var attributes: AttributesValue
}

extension RawAnalyticsEvent {
    init(analyticsEvent: some AnalyticsEvent) {
        self.name = analyticsEvent.name
        var attributes = AttributesValue()
        attributes["trigger"] = analyticsEvent.trigger.name
        attributes["category"] = analyticsEvent.category.name
        let otherAttributeValues = analyticsEvent.otherAttributes?.serialiseToValue()
        if let otherAttributeValues {
            for (key, value) in otherAttributeValues {
                print(key, value)
                attributes[key] = value
            }
        }
        self.attributes = attributes
    }
}
