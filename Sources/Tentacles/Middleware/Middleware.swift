//
//  Middleware.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

public protocol Middleware {
    func transform(_ analyticsEvent: RawAnalyticsEvent) -> RawAnalyticsEvent
}
