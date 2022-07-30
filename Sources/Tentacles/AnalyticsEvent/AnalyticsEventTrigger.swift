//
//  AnalyticsEventAction.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

public protocol AnalyticsEventTrigger {
    var name: String { get }
}

public enum TentaclesEventTrigger: String, AnalyticsEventTrigger {
    case clicked
    case didEnterForeground
    case screenDidAppear
    case willResignActive
    
    public var name: String {
        self.rawValue
    }
}
