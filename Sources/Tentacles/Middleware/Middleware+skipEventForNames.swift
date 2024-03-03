//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// Skips event that matches a name provided with names.
    ///
    /// - Parameter names: Names of the event that will be skipped.
    static func skipEvent(for names: [String]) -> Self {
        return Self { event -> Action in
            names.contains(event.name) ? .skip : .forward(event)
        }
    }
}
