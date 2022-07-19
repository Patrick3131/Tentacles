//
//  AnalyticsEventAction.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

public typealias AnalyticsEventTrigger = String

public extension AnalyticsEventTrigger {
    static let clicked = "clicked"
    static let navigated = "navigated"
    static let openedScreen = "openedScreen"
}
