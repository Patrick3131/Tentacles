//
//  File.swift
//  
//
//  Created by Patrick Fischer on 03.03.24.
//

import Foundation

public extension Middleware where Item == RawAnalyticsEvent {
    /// ``Middleware`` to calculate the duration between two status of ``DomainActivityAction`` related to a ``DomainActivity``.
    ///
    /// ``RawAnalyticsEvent``s that will be transformed need to be of category
    ///  domainActivity, and need to be derived by a ``DomainActivity`` that
    ///  has been affected by a ``DomainActivityAction`` with both status.
    ///  If successful transformed a new duration attribute with a Double will be added
    ///  to the attributes.
    ///
    /**
     calculateDomainActivityDuration(
     between: .open,
     and: .completed)
     */
    /// In case of a successful transformation this would add a double value with **durationOpenedCompleted** as a key to the the attributes of ``RawAnalyticsEvent``.
    static func calculateDomainActivityDuration(
        between status: DomainActivityAction.Status,
        and otherStatus: DomainActivityAction.Status)
    -> Self {
        return Self { event -> Action in
            do {
                let category: String = try event.getAttributeValue(
                    for: KeyAttributes.category)
                if category == TentaclesEventCategory.domainActivity.rawValue {
                    let statusValue: Double = try event.getAttributeValue(
                        for: status.derivedAttributesKey)
                    let otherStatusValue: Double = try event.getAttributeValue(
                        for: otherStatus.derivedAttributesKey)
                    var newEvent = event
                    let duration = otherStatusValue - statusValue
                    let key = "duration\(status.derivedAttributesKey.capitalized)\(otherStatus.derivedAttributesKey.capitalized)"
                    newEvent.attributes[key] = duration
                    return .forward(newEvent)
                }
                return .forward(event)
            } catch {
                return .forward(event)
            }
        }
    }
}

fileprivate extension DomainActivityAction.Status {
    var derivedAttributesKey: String {
        switch self {
        case .open: return "opened"
        case .start: return "started"
        case .pause: return "paused"
        case .cancel: return "canceled"
        case .complete: return "completed"
        }
    }
}
