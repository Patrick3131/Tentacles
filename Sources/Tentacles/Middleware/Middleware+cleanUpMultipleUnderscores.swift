//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation
import os

public extension Middleware where Item == RawAnalyticsEvent {
    static let cleanUpMultipleUnderscores = Self { event -> Action in
        var updatedEvent = event
        do {
            let regexPattern = "__+" // Matches two or more consecutive underscores
            let regex = try NSRegularExpression(pattern: regexPattern, options: [])
            let range = NSRange(location: 0, length: updatedEvent.name.utf16.count)
            updatedEvent.name = regex.stringByReplacingMatches(in: updatedEvent.name, options: [], range: range, withTemplate: "_")
            return .forward(updatedEvent)
        } catch {
            Logger().error("\(error.localizedDescription)")
            return .forward(event)
        }
    }
}
