//
//  File.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

public struct RawAnalyticsEvent {
    let name: String
    var attributes: AttributesValue
}

extension RawAnalyticsEvent {
    init(analyticsEvent: some AnalyticsEvent) {
        self.name = analyticsEvent.name
        var attributes = AttributesValue()
        attributes["trigger"] = analyticsEvent.trigger
        attributes["category"] = analyticsEvent.category
        let otherAttributeValues = analyticsEvent.otherAttributes?.serialiseToValue()
        if let otherAttributeValues {
            for (key, value) in otherAttributeValues {
                print(key, value)
                attributes[key] = value
            }
        }
        self.attributes = attributes
        
    }
}
