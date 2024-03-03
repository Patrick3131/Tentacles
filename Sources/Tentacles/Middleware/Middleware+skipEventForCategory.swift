//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// Skips event that matches a category.
    ///
    /// - Parameter category: Category of the event that will be skipped.
    static func skipEvent(for category: AnalyticsEventCategory)
    -> Self {
        return Self { event -> Action in
            do {
                let categoryValue: String = try event.getAttributeValue(
                    for: KeyAttributes.category)
                if categoryValue == category.name {
                    return .skip
                }
                return .forward(event)
            } catch {
                return .forward(event)
            }
        }
    }
}
