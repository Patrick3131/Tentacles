//
//  AnalyticsEventCategory.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

public protocol AnalyticsEventCategory {
    var name: String { get }
}

public enum TentaclesEventCategory: String, AnalyticsEventCategory {
    case lifecyle
    case navigation
    case interaction
    case valueProposition

    
    public var name: String {
        self.rawValue
    }
}
