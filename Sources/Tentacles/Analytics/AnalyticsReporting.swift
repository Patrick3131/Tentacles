//
//  AnalyticsReporter.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

/// Abstraction to implement a specific analytics reporter, this could be the apps backend,
/// a third party service like Firebase or a local logger
///
///Example for Logger implementation:
/// ````
///struct TentaclesLogger: AnalyticsReporting {
///    private var logger = Logger()
///
///    func identify(with id: String) {
///        logger.log("User logged in with \(id) id")
///    }
///
///    func logout() {
///        logger.log("User logged out")
///    }
///
///    func addUserAttributes(_ attributes: AttributesValue) {
///        logger.log("Attributes added: \(attributes)")
///    }
///
///    func setup() {
///        logger.info("Tentacles logger set up")
///    }
///
///    func report(event: RawAnalyticsEvent) {
///        logger.log("Analytics event: \(event.name), with attributes: \(event.attributes)")
///    }
///
///    func report(_ error: Error) {
///        logger.critical("\(error.localizedDescription)")
///    }
///}
/// ````
public protocol AnalyticsReporting: UserIdentifying, NonFatalErrorReporting {
    /// Used to set up i.e. the underlying third party service
    ///
    /// Setup is called when the reporter is registered to the register.
    func setup()
    func report(event: RawAnalyticsEvent)
    func addUserAttributes(_ attributes: AttributesValue)
}
