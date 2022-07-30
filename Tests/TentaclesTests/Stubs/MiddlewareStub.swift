//
//  MiddlewareStub.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation
import Tentacles

extension Middleware {
    static let skipTestEvent: Self = Self { event -> RawAnalyticsEvent? in
        if event.name == "Test" {
            return nil
        }
        return event
    }
}
