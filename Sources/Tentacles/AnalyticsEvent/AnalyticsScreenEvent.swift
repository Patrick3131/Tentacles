//
//  AnalyticsScreenEvent.swift
//  
//
//  Created by Patrick Fischer on 02.08.22.
//

import Foundation

/// An event that can be reported with `AnalyticsEventTracking`` which represents the display of a screen .
public struct AnalyticsScreenEvent<Attributes: TentaclesAttributes>: AnalyticsEvent {
    public let category: AnalyticsEventCategory = TentaclesEventCategory.screen
    public let trigger: AnalyticsEventTrigger = TentaclesEventTrigger.screenDidAppear
    public let name: String
    public let otherAttributes: Attributes
    public init(name: String, otherAttributes: Attributes = EmptyAttributes()) {
        self.name = name
        self.otherAttributes = otherAttributes
    }
}
