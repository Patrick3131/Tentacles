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
    static let automatically = "automatically"
    static let navigated = "navigated"
    static let openedScreen = "openedScreen"
    static let didEnterBackground = "didEnterBackground"
    static let didEnterForeground = "didEnterForeground"
}
