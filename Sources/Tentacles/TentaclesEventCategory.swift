//
//  TentaclesEventCategory.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public enum TentaclesEventCategory: String, AnalyticsEventCategory {
    case lifecycle
    case navigation
    case interaction
    case valueProposition
    case screen
    
    public var name: String {
        self.rawValue
    }
}
