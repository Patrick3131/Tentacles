//
//  TentaclesLogger.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation
import os

struct TentaclesLogger: AnalyticsReporting {
    func report(_ error: Error, filename: String, line: Int) {
        logger.critical("\(error.localizedDescription)")
    }
    
    private var logger = Logger()
    
    func identify(with id: String) {
        logger.log("User logged in with \(id) id")
    }
    
    func logout() {
        logger.log("User logged out")
    }
    
    func addUserAttributes(_ attributes: AttributesValue) {
        logger.log("Attributes added: \(attributes)")
    }
    
    func setup() {
        logger.info("Tentacles logger set up")
    }
    
    func report(event: RawAnalyticsEvent) {
        logger.log("Analytics event: \(event.name), with attributes: \(event.attributes)")
    }
}
