//
//  AnalyticsEventCategory.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

public typealias AnalyticsEventCategory = String

public extension AnalyticsEventCategory {
    static let valueProposition = "valueProposition"
    static let navigation = "navigation"
    static let interaction = "interaction"
    static let lifecycle = "lifecycle"
}
