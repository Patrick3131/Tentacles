import Foundation

struct ValuePropositionSession {
    enum Status: String, Encodable {
        case opened
        case started
        case paused
        case canceled
        case completed
    }
    private var uuid = UUID()
    var status: Status
    let valueProposition: any ValueProposition
    
    /// When first created the status is set to opened.
    init(valueProposition: any ValueProposition) {
        self.valueProposition = valueProposition
        self.status = .opened
    }
    
    /// sets UUID to a new UUID, this is used if a new session with the same property values is needed
    mutating func reset() {
        uuid = UUID()
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
            attributes["uuid"] = uuid.uuidString
            attributes["status"] = status.rawValue
            attributes["trigger"] = trigger.name
            attributes["category"] = TentaclesEventCategory.valueProposition.name
            attributes = combine(attributes, with: valueProposition.attributes)
            return attributes
        }
}
