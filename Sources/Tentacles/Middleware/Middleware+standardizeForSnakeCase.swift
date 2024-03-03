//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// `Middleware` to standardize event names by applying multiple transformations.
    /// This includes converting to snake_case, ensuring lowercase, replacing spaces with underscores,
    /// cleaning up multiple underscores, and removing special characters.
    static let standardizeForSnakeCase = Self { event -> Action in
        var updatedEvent = event
        // Replace spaces with underscores and convert to snake case in one pass
        updatedEvent.name = updatedEvent.name
            .replacingOccurrences(of: " +", with: "_", options: .regularExpression) // Spaces to underscore
            .camelCaseToSnakeCase() // Camel case to snake case
            .lowercased() // Ensure lowercase
            .replacingOccurrences(of: "_+", with: "_", options: .regularExpression) // Clean up multiple underscores
            // Remove non-alphanumeric characters except underscore
            .replacingOccurrences(of: "[^a-zA-Z0-9_]", with: "", options: .regularExpression)

        return .forward(updatedEvent)
    }
}
