//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// Converts the event name of a `RawAnalyticsEvent` to lowercase.
    ///
    /// This middleware takes the original event name, transforms it to lowercase,
    /// and forwards the event for further processing or dispatch. This standardization
    /// can be useful for analytics platforms that are case-sensitive or to maintain
    /// consistent naming conventions.
    ///
    /// Example:
    /// - Original event name: `"UserSignUp"`
    /// - Modified event name: `"usersignup"`
    static let lowercaseEventName = Self { event -> Action in
        var updatedEvent = event
        updatedEvent.name = updatedEvent.name.lowercased()
        return .forward(updatedEvent)
    }
}
