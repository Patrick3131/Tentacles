//
//  ValuePropositionSession.swift
//
//
//  Created by Patrick Fischer on 22.07.22.
//

import Foundation

struct ValuePropositionSession {
    /// Possible status
    enum Status: String, Encodable {
        case opened
        case started
        case paused
        case canceled
        case completed
    }
    
    private var statusTimestamps = [Status: [Double]]()
    private(set) var identifier = SessionIdentifier()
    let valueProposition: RawValueProposition
    var status: Status {
        didSet {
            addTimestamp(for: status)
        }
    }
    
    /// When first created the status is set to opened.
    init(for valueProposition: RawValueProposition) {
        self.valueProposition = valueProposition
        self.status = .opened
        addTimestamp(for: status)
    }
    
    /// Sets UUID to a new UUID, and removes all timestamps for previous status changes.
    mutating func reset() {
        identifier.reset()
        statusTimestamps = [:]
    }
    
    func makeRawAnalyticsEvent(action: ValuePropositionAction) -> RawAnalyticsEvent {
        var attributes = makeDefaultAttributes(trigger: action.trigger)
        attributes = combine(attributes, with: action.attributes)
        return RawAnalyticsEvent(name: valueProposition.name, attributes: attributes)
    }
    
    func makeRawAnalyticsEvent(trigger: AnalyticsEventTrigger) -> RawAnalyticsEvent {
        let attributes = makeDefaultAttributes(trigger: trigger)
        return RawAnalyticsEvent(name: valueProposition.name,
                                 attributes: attributes)
    }
    
    private func combine(_ attributes: AttributesValue,
                         with tentacleAttributes: (any TentaclesAttributes)?) -> AttributesValue {
        var newAttributes = attributes
        if let tentacleAttributes {
            for (key, value) in tentacleAttributes.serialiseToValue() {
                newAttributes[key] = value
            }
        }
        return newAttributes
    }
    
    mutating private func addTimestamp(for status: Status) {
        let timestamp = Date.timeIntervalSinceReferenceDate
        if var timestamps = statusTimestamps[status] {
            timestamps.append(timestamp)
            statusTimestamps[status] = timestamps
        } else {
            statusTimestamps[status] = [timestamp]
        }
    }
    
    private func makeTimestampAttributes(_ attributes: AttributesValue) -> AttributesValue {
        var newAttributes = attributes
        for timestamp in statusTimestamps {
            for (index, value) in timestamp.value.enumerated() {
                if index == 0 {
                    newAttributes[timestamp.key.rawValue] = value
                } else {
                    newAttributes[timestamp.key.rawValue + "_" + "\(index)"] = value
                }
            }
        }
        return newAttributes
    }
    
    private func makeDefaultAttributes(
        trigger: AnalyticsEventTrigger) -> AttributesValue {
            var attributes = makeTimestampAttributes(AttributesValue())
            attributes[KeyAttributes.valuePropositionSessionUUID] = identifier.id.uuidString
            attributes[KeyAttributes.status] = status.rawValue
            attributes[KeyAttributes.trigger] = trigger.name
            attributes[KeyAttributes.category] = TentaclesEventCategory.valueProposition.name
            attributes = combine(attributes, with: valueProposition.attributes)
            return attributes
        }
}
