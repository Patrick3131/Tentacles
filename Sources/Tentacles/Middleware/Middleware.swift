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

public extension Middleware {
    static let capitalisedAttributeKeys: Self = Self { event -> RawAnalyticsEvent in
        var attributes = AttributesValue()
        event.attributes.forEach {
            attributes[$0.key.capitalized] = $0.value
        }
        return RawAnalyticsEvent(name: event.name, attributes: attributes)
    }
}
