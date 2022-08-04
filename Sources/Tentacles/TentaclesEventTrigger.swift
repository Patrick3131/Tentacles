//
//  TentaclesEventTrigger.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public enum TentaclesEventTrigger: String, AnalyticsEventTrigger {
    case clicked
    case didEnterForeground
    case screenDidAppear
    case willResignActive
    case userInitiated
    
    public var name: String {
        self.rawValue
    }
}
