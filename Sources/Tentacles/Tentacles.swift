//
//  Tentacles.swift
//  
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation
import Combine
#if canImport (AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif

/// Tentacles provides methods for registering ``AnalyticsReporting``services,
///  tracking ``AnalyticsEvent``s, ``DomainActivity``s and non-fatal errors, identifying the user at
///  ``AnalyticsReporting``services and setting user attributes.
///
/// For documentation check out the Protocols and the top level README.
public class Tentacles: AnalyticsRegister, UserIdentifying, AnalyticsEventTracking, NonFatalErrorReporting {
    private typealias AnalyticsUnit = (reporter: any AnalyticsReporting, middlewares: [Middleware<RawAnalyticsEvent>])
    private var analyticsUnit = [AnalyticsUnit]()
    private var middlewares = [Middleware<RawAnalyticsEvent>]()
    private var domainActivitySessionManager: DomainActivitySessionManager?
    private var domainActivityEventsSubscription: AnyCancellable?
    
    private var identifier = SessionIdentifier()
    
#if canImport(UIKit) || canImport(AppKit)
    private var willResignActiveSubscription: AnyCancellable?
    private var didBecomeActiveSubscription: AnyCancellable?
    private let notificationCenter: NotificationCenter
    
    public init(notificationCenter: NotificationCenter = NotificationCenter.default) {
        self.notificationCenter = notificationCenter
        subscribeToBackgroundAndForegroundNotifications()
    }
    
#else
    public init() {}
#endif
    
    public func register(_ middleware: Middleware<RawAnalyticsEvent>) {
        middlewares.append(middleware)
    }
    
    public func register(_ analyticsReporter: any AnalyticsReporting, with middlewares: [Middleware<RawAnalyticsEvent>] = []) {
        analyticsReporter.setup()
        let analyticsUnit: AnalyticsUnit = (reporter: analyticsReporter, middlewares: middlewares)
        self.analyticsUnit.append(analyticsUnit)
    }
    
    public func reset() {
        analyticsUnit = []
        middlewares = []
        identifier.reset()
    }
    
    public func identify(with id: String) {
        analyticsUnit.forEach { $0.reporter.identify(with: id)}
    }
    
    public func logout() {
        analyticsUnit.forEach { $0.reporter.logout() }
    }
    
    public func addUserAttributes(_ attributes: TentaclesAttributes) {
        let attributesValue = attributes.serialiseToValue()
        analyticsUnit.forEach { $0.reporter.addUserAttributes(attributesValue) }
    }

    public func track(_ event: AnalyticsEvent<some TentaclesAttributes>) {
        var rawEvent = RawAnalyticsEvent(analyticsEvent: event)
        rawEvent.attributes[KeyAttributes.sessionUUID] = identifier.id.uuidString
       track(rawEvent)
    }

    public func report(_ error: Error, filename: String = #file, line: Int = #line) {
        analyticsUnit.forEach { $0.reporter.report(
            error, filename: filename, line: line) }
    }

    public func track(_ domainActivity: DomainActivity<some  TentaclesAttributes>, with action: DomainActivityAction) {
        if domainActivitySessionManager == nil,
           domainActivityEventsSubscription == nil {
            domainActivitySessionManager = .init()
            domainActivityEventsSubscription = domainActivitySessionManager?
                .eventPublisher
                .sink(receiveValue: { [weak self] results in
                    switch results {
                    case .success(let event):
                        self?.track(event)
                    case .failure(let error):
                        self?.report(error)
                    }
                })
        }
        let rawDomainActivity = RawDomainActivity(from: domainActivity)
        domainActivitySessionManager?.process(rawDomainActivity,
                                                with: action)
    }
    
    fileprivate func track(_ event: RawAnalyticsEvent) {
        var newEvent: RawAnalyticsEvent? = event
        newEvent?.attributes[KeyAttributes.sessionUUID] = identifier.id.uuidString
        newEvent = middlewares.transform(newEvent)
        analyticsUnit.forEach { (reporter, middlewares) in
            let specificEvent = middlewares.transform(newEvent)
            if let specificEvent {
                reporter.report(specificEvent)
            }
        }
    }
    
#if canImport(UIKit) || canImport(AppKit)
    private func subscribeToBackgroundAndForegroundNotifications() {
#if canImport(UIKit)
        let willResignActiveNotification = UIApplication.willResignActiveNotification
        let didBecomeActiveNotification = UIApplication.didBecomeActiveNotification
#elseif canImport(AppKit)
        let willResignActiveNotification = NSApplication.willResignActiveNotification
        let didBecomeActiveNotification = NSApplication.didBecomeActiveNotification
#endif
        willResignActiveSubscription = notificationCenter
            .publisher(for: willResignActiveNotification)
            .sink { [weak self] _ in
                self?.domainActivitySessionManager?.processWillResign()
            }
        didBecomeActiveSubscription = notificationCenter
            .publisher(for: didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.identifier.reset()
                self?.domainActivitySessionManager?.processDidBecomeActive()
            }
    }
#endif
}
