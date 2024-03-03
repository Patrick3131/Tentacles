//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// `Middleware` to transform event names from camelCase to snake_case.
    static let camelCaseToSnakeCaseEventName = Self { event -> Action in
        var updatedEvent = event
        updatedEvent.name = event.name.camelCaseToSnakeCase()
        return .forward(updatedEvent)
    }
}
