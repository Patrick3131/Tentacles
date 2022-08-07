//
//  RawAnalyticsEvent+Extension.swift
//  
//
//  Created by Patrick Fischer on 07.08.22.
//

import Foundation
@testable import Tentacles

extension RawAnalyticsEvent {
    /// Adds the possibility to create RawAnalyticsEvent from scratch without an AnalyticsEvent to
    /// make testing easier.
    init() {
        self.init(name: "TestRawAnalyticsEvent")
    }
    
    init(name: String) {
        self.init(name: name, attributes: [:])
    }
}
