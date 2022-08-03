//
//  ValuePropositionSession.swift
//
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation

struct ValuePropositionSession {
    enum Status: String, Encodable {
        case opened
        case started
        case paused
        case canceled
        case completed
    }
    private(set) var identifier = SessionIdentifier()
    var status: Status {
        didSet {
            timestamps[status] = Date.timeIntervalSinceReferenceDate
        }
    }
    private var timestamps = [Status: Double]()
    let valueProposition: any ValueProposition
    
    /// When first created the status is set to opened.
    init(valueProposition: any ValueProposition) {
        self.valueProposition = valueProposition
        self.status = .opened
    }
    
    /// sets UUID to a new UUID, this is used if a new session with the same property values is needed
    mutating func reset() {
        identifier.reset()
    }
    
    func createRawAnalyticsEvent(action: ValuePropositionAction) -> RawAnalyticsEvent {
        var attributes = buildDefaultAttributes(trigger: action.trigger)
        attributes = combine(attributes, with: action.attributes)
        return RawAnalyticsEvent(name: valueProposition.name, attributes: attributes)
    }
    
    func createRawAnalyticsEvent(trigger: AnalyticsEventTrigger) -> RawAnalyticsEvent {
        let attributes = buildDefaultAttributes(trigger: trigger)
        return RawAnalyticsEvent(name: valueProposition.name,
                                 attributes: attributes)
    }
    
    private func combine(_ attributes: AttributesValue,
                         with tentacleAttributes: (any TentacleAttributes)?) -> AttributesValue {
        var newAttributes = attributes
        if let tentacleAttributes {
            for (key, value) in tentacleAttributes.serialiseToValue() {
                newAttributes[key] = value
            }
        }
        return newAttributes
    }
    
    private func buildDefaultAttributes(
        trigger: AnalyticsEventTrigger) -> AttributesValue {
            var attributes = AttributesValue()
            for timestamp in timestamps {
                attributes[timestamp.key.rawValue+"At"] = timestamp.value
            }
            attributes[KeyAttributes.valuePropositionSessionUUID] = identifier.id.uuidString
            attributes[KeyAttributes.status] = status.rawValue
            attributes[KeyAttributes.trigger] = trigger.name
            attributes[KeyAttributes.category] = TentaclesEventCategory.valueProposition.name
            attributes = combine(attributes, with: valueProposition.attributes)
            return attributes
        }
}
