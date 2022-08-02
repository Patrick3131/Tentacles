//
//  PFActivityAction.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

/// Action to trigger an update of the ValuePropositionSession
public struct ValuePropositionAction {
    public enum Status {
        case open
        case start
        case pause
        case cancel
        case complete
    }
    /// Defines the status action that triggers an update of the session of ValuePropositionSession.
    public let status: Status
    public let trigger: AnalyticsEventTrigger
    public let attributes: TentacleAttributes?
    
    public init(status: Status,
                trigger: AnalyticsEventTrigger,
                attributes: TentacleAttributes? = nil) {
        self.status = status
        self.trigger = trigger
        self.attributes = attributes
    }
}

public extension ValuePropositionAction {
    static func open(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                     attributes: TentacleAttributes? = nil) -> Self {
        Self.init(status: .open,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func start(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                      attributes: TentacleAttributes? = nil) -> Self {
        Self.init(status: .start,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func pause(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                      attributes: TentacleAttributes? = nil) -> Self {
        Self.init(status: .pause,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func complete(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                         attributes: TentacleAttributes? = nil) -> Self {
        Self.init(status: .complete,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func cancel(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                       attributes: TentacleAttributes? = nil) -> Self {
        Self.init(status: .cancel,
                  trigger: trigger,
                  attributes: attributes)
    }
}
