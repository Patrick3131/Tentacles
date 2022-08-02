//
//  AnalyticsScreenEvent.swift
//  
//
//  Created by Patrick Fischer on 02.08.22.
//

import Foundation

struct AnalyticsScreenEvent<Attributes: TentacleAttributes>: AnalyticsEvent {
    let category: AnalyticsEventCategory = TentaclesEventCategory.screen
    let trigger: AnalyticsEventTrigger = TentaclesEventTrigger.screenDidAppear
    let name: String
    let otherAttributes: Attributes?
    public init(name: String, otherAttributes: Attributes?) {
        self.name = name
        self.otherAttributes = otherAttributes
    }
}
