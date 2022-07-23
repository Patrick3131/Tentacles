//
//  Middleware.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

protocol Middleware {
    func transform(_ analyticsEvent: RawAnalyticsEvent) -> RawAnalyticsEvent
}

struct ValuePropositionSessionMiddleware: Middleware {
    func transform(_ analyticsEvent: RawAnalyticsEvent) -> RawAnalyticsEvent {
        var newAnalyticsEvent = analyticsEvent
        let categoryKey = "category"
        let attributesKey = ValuePropositionSession.Attributes
            .CodingKeys.valuePropostionAttributes.rawValue
        let categoryValue = analyticsEvent.attributes[categoryKey] as? String
        if analyticsEvent.attributes[categoryKey] as? String == .valueProposition,
           let attributes = analyticsEvent.attributes[attributesKey] as? [String: AnyHashable] {
            for (key, value) in attributes {
                newAnalyticsEvent.attributes[key] = value
            }
            newAnalyticsEvent.attributes[attributesKey] = nil
        }
        return newAnalyticsEvent
    }
}
