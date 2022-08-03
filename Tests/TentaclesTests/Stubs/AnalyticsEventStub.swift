//
//  AnalyticsEventStub.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation
import Tentacles

struct AnalyticsEventStub: AnalyticsEvent {
    typealias Attributes = KeyValueAttribute<Int>
    
    var category: AnalyticsEventCategory
    
    var trigger: AnalyticsEventTrigger
    
    var name: String
    
    var otherAttributes: Attributes
}

extension AnalyticsEventStub {
    init() {
        self.category = TentaclesEventCategory.interaction
        self.trigger = TentaclesEventTrigger.clicked
        self.name = "Test"
        self.otherAttributes = KeyValueAttribute(key: "test", value: 123)
    }
}

