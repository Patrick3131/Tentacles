//
//  AnalyticsEventStub.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation
import Tentacles

typealias AnalyticsEventStub = AnalyticsEvent<KeyValueAttribute<Int>>

extension AnalyticsEventStub {
    init() {
        self.init(category: TentaclesEventCategory.interaction,
                  trigger: TentaclesEventTrigger.clicked,
                  name: "Test",
                  otherAttributes: KeyValueAttribute(key: "test", value: 123))
    }
}

