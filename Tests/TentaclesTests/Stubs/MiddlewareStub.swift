//
//  MiddlewareStub.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation
import Tentacles

extension Middleware where Item == RawAnalyticsEvent {
    static let skipTestEvent: Self = Self { event -> Action in
        if event.name == "Test" {
            return .skip
        }
        return .forward(event)
    }
}
