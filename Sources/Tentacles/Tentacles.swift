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

public class Tentacles: AnalyticsRegister {
    private typealias AnalyticsUnit = (reporter: any AnalyticsReporting, middlewares: [Middleware<RawAnalyticsEvent>])
    private var analyticsUnit = [AnalyticsUnit]()
    private var middlewares = [Middleware<RawAnalyticsEvent>]()
    private var valuePropositionSessionManager: ValuePropositionSessionManager?
    private var valuePropositionEventsSubscription: AnyCancellable?
    
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
    
    public func register(analyticsReporter: any AnalyticsReporting, middlewares: [Middleware<RawAnalyticsEvent>] = []) {
        analyticsReporter.setup()
        let analyticsUnit: AnalyticsUnit = (reporter: analyticsReporter, middlewares: middlewares)
        self.analyticsUnit.append(analyticsUnit)
    }
    
    public func resetRegister() {
        analyticsUnit = []
        middlewares = []
    }
    
    fileprivate func track(_ event: RawAnalyticsEvent) {
        var newEvent: RawAnalyticsEvent? = event
        newEvent?.attributes[KeyAttributes.sessionUUID] = identifier.id.uuidString
        middlewares.forEach { middleware in
            switch middleware.closure(event) {
            case .forward(let event):
                newEvent = event
            case .skip:
                newEvent = nil
            }
        }
        analyticsUnit.forEach { (reporter, middlewares) in
            middlewares.forEach { middleware in
                if let unwrappedEvent = newEvent {
                    switch middleware.closure(unwrappedEvent) {
                    case .forward(let event):
                        newEvent = event
                    case .skip:
                        newEvent = nil
                    }
                }
            }
            if let newEvent {
                reporter.report(event: newEvent)
            }
        }
    }
}

extension Tentacles: UserIdentifying {
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
}

extension Tentacles: AnalyticsEventReporting {
    public func report(_ event: any AnalyticsEvent) {
       track(RawAnalyticsEvent(analyticsEvent: event))
    }
}

extension Tentacles: NonFatalErrorReporting {
    public func report(_ error: Error, filename: String = #file, line: Int = #line) {
        analyticsUnit.forEach { $0.reporter.report(
            error, filename: filename, line: line) }
    }
}

extension Tentacles: ValuePropositionReporting {
    public func report(for valueProposition: any ValueProposition, with action: ValuePropositionAction) {
        if valuePropositionSessionManager == nil,
           valuePropositionEventsSubscription == nil {
            valuePropositionSessionManager = .init()
            valuePropositionEventsSubscription = valuePropositionSessionManager?
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
        valuePropositionSessionManager?.process(for: valueProposition,
                                                      with: action)
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
                self?.valuePropositionSessionManager?.processWillResign()
            }
        didBecomeActiveSubscription = notificationCenter
            .publisher(for: didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.identifier.reset()
                self?.valuePropositionSessionManager?.processDidBecomeActive()
            }
    }
#endif
}
