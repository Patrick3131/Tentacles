//
//  Middleware.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

public struct Middleware {
    let closure: (RawAnalyticsEvent) -> RawAnalyticsEvent
    init(_ closure: @escaping (RawAnalyticsEvent) -> RawAnalyticsEvent) {
        self.closure = closure
    }
}
