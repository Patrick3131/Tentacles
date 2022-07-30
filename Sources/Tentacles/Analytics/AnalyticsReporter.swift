//
//  AnalyticsReporter.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

public protocol AnalyticsReporter {
    func setup()
    func report(event: RawAnalyticsEvent)
}

