//
//  PFActivityAction.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

/// Action to trigger an update of the ValuePropositionActivity
public struct ValuePropositionAction {
    public enum Status {
        case open
        case start
        case pause
        case cancel
        case complete
    }
    
    let status: Status
    let trigger: AnalyticsEventTrigger
    let attributes: AnalyticsEventAttributes?

    public init(status: Status,
                trigger: AnalyticsEventTrigger,
                attributes: AnalyticsEventAttributes? = nil) {
        self.status = status
        self.trigger = trigger
        self.attributes = attributes
    }
}

extension ValuePropositionAction {
    static func builder(status: Status,
                        trigger: AnalyticsEventTrigger = .clicked,
                        attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: status,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func open(trigger: AnalyticsEventTrigger = .clicked,
                     attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: .open,
                  trigger: trigger,
                  attributes: attributes)
    }
    static func start(trigger: AnalyticsEventTrigger = .clicked,
                      attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: .start,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func pause(trigger: AnalyticsEventTrigger = .clicked,
                      attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: .pause,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func complete(trigger: AnalyticsEventTrigger = .clicked,
                      attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: .complete,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func cancel(trigger: AnalyticsEventTrigger = .clicked,
                      attributes: AnalyticsEventAttributes? = nil) -> Self {
        Self.init(status: .cancel,
                  trigger: trigger,
                  attributes: attributes)
    }
}
