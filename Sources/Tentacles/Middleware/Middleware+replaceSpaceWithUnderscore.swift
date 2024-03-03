//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// Replaces spaces in the event name of a `RawAnalyticsEvent` with underscores.
    ///
    /// This middleware searches for spaces within the event name and replaces them
    /// with underscores. This can be particularly useful when the analytics platform
    /// or data storage system does not support spaces in naming conventions.
    ///
    /// Example:
    /// - Original event name: `"User Sign Up"`
    /// - Modified event name: `"User_Sign_Up"`
    static let replaceSpaceWithUnderscore = Self { event -> Action in
        var updatedEvent = event
        updatedEvent.name = updatedEvent.name.replacingOccurrences(of: " ", with: "_")
        return .forward(updatedEvent)
    }
}
