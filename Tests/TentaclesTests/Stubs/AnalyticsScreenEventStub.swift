//
//  AnalyticsScreenEventStub.swift
//  
//
//  Created by Patrick Fischer on 08.08.22.
//

import Foundation
import Tentacles

typealias AnalyticsScreenEventStub = AnalyticsEvent<EmptyAttributes>

extension AnalyticsScreenEventStub {
    init(name: String = "screenEvent",
         category: AnalyticsEventCategory = TentaclesEventCategory.screen,
         trigger: AnalyticsEventTrigger = TentaclesEventTrigger.screenDidAppear) {
        self.init(category: category, trigger: trigger, name: name, otherAttributes: EmptyAttributes())
    }
}
