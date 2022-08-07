//
//  MiddlewareStub.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation
import Tentacles

extension Middleware where Item == RawAnalyticsEvent {
    /// Skips events with a name equal to "Test".
    static let skipTestEvent: Self = Self { event -> Action in
        if event.name == "Test" {
            return .skip
        }
        return .forward(event)
    }
    
    /// Changes name of event to lowercase.
    static let lowercaseEventName: Self = Self { event -> Action in
        var newEvent = event
        newEvent.name = newEvent.name.lowercased()
        return .forward(newEvent)
    }
}
