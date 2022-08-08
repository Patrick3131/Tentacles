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
    static let eventName: String = "Test"
    /// ``AnalyticsEvent`` with category - interaction, trigger - clicked, name - "Test", and a ``KeyValueAttribute<Int>`` with key "test" and value 123.
    init() {
        self.init(category: TentaclesEventCategory.interaction,
                  trigger: TentaclesEventTrigger.clicked,
                  name: Self.eventName,
                  otherAttributes: KeyValueAttribute(key: "test", value: 123))
    }
}

