//
//  AnalyticsEventTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol AnalyticsEventTracking {
    func track(_ event: AnalyticsEvent<some TentaclesAttributes>)
}
