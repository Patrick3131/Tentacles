//
//  PFActivityAction.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation

/// Action to trigger an update of a ``DomainActivity`` session.
public struct DomainActivityAction {
    /// Possible status updates for a ``DomainActivity`` session.
    ///
    /// Status changes that are allowed:
    ///
    ///```mermaid
    /// Open --> Start
    /// Open --> Cancel
    /// Start --> Pause
    /// Start --> Complete
    /// Start --> Cancel
    /// Pause --> Start
    /// Pause --> Cancel
    ///```
    /// If a prohibited status update occurs a non fatal error event is forwarded and the status is **not** updated.
    public enum Status {
        case open
        case start
        case pause
        case cancel
        case complete
    }
    /// Defines the status action that triggers a status update of a ``DomainActivity`` session.
    public let status: Status
    public let trigger: AnalyticsEventTrigger
    /// Attributes related to a specific status update of ``DomainActivity`` and not the the ``DomainActivity`` itself.
    ///
    /// Attributes are mapped to the attributes of ``RawAnalyticsEvent``, when ``RawAnalyticsEvent`` is derived from ``DomainActivity``.
    public let attributes: TentaclesAttributes?
    
    public init(status: Status,
                trigger: AnalyticsEventTrigger,
                attributes: TentaclesAttributes? = nil) {
        self.status = status
        self.trigger = trigger
        self.attributes = attributes
    }
}

public extension DomainActivityAction {
    static func open(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                     attributes: TentaclesAttributes? = nil) -> Self {
        Self.init(status: .open,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func start(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                      attributes: TentaclesAttributes? = nil) -> Self {
        Self.init(status: .start,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func pause(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                      attributes: TentaclesAttributes? = nil) -> Self {
        Self.init(status: .pause,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func complete(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                         attributes: TentaclesAttributes? = nil) -> Self {
        Self.init(status: .complete,
                  trigger: trigger,
                  attributes: attributes)
    }
    
    static func cancel(trigger: AnalyticsEventTrigger = TentaclesEventTrigger.clicked,
                       attributes: TentaclesAttributes? = nil) -> Self {
        Self.init(status: .cancel,
                  trigger: trigger,
                  attributes: attributes)
    }
}
