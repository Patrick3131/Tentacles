//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// Capitalizes the keys of all attributes within a `RawAnalyticsEvent`.
    ///
    /// This middleware iterates over each attribute key-value pair in the event's attributes,
    /// capitalizing the keys while preserving the values unchanged. The modified event is then
    /// forwarded for further processing or dispatch.
    ///
    /// Example:
    /// - Original attributes: `["first_name": "John", "last_age": 30]`
    /// - Modified attributes: `["First_name": "John", "Last_age": 30]`
    static let capitalisedAttributeKeys = Self { event -> Action in
        var attributes = AttributesValue()
        event.attributes.forEach {
            attributes[$0.key.capitalized] = $0.value
        }
        return .forward(RawAnalyticsEvent(name: event.name, attributes: attributes))
    }
}
