//
//  AnalyticsEventTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol AnalyticsEventReporting {
    func report(_ event: any AnalyticsEvent)
}
