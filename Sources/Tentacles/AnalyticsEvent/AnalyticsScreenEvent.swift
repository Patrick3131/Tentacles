//
//  AnalyticsScreenEvent.swift
//  
//
//  Created by Patrick Fischer on 02.08.22.
//

import Foundation

/// An event that can be reported with `AnalyticsEventReporting`` which represents the display of a screen .
struct AnalyticsScreenEvent<Attributes: TentaclesAttributes>: AnalyticsEvent {
    let category: AnalyticsEventCategory = TentaclesEventCategory.screen
    let trigger: AnalyticsEventTrigger = TentaclesEventTrigger.screenDidAppear
    let name: String
    let otherAttributes: Attributes?
    public init(name: String, otherAttributes: Attributes? = nil) {
        self.name = name
        self.otherAttributes = otherAttributes
    }
}
