//
//  TentaclesLogger.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation
import os

struct TentaclesLogger: AnalyticsReporter {
    private var logger = Logger()
    func setup() {
        logger.info("Tentacles logger set up")
    }
    
    func report(event: RawAnalyticsEvent) {
        logger.log("Analytics event:\(event.name), with attributes: \(event.attributes)")
    }
}

extension TentaclesLogger: NonFatalErrorTracking {
    func track(_ error: Error) {
        logger.critical("\(error.localizedDescription)")
    }
}

