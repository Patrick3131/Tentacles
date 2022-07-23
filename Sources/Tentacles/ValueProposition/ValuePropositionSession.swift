/*
 Activity is a process of a user that will be tracked.
 It needs to be identifiable.
 It has a status Options (open, start, paused?, cancelled, completed)
 It has attributes
 */
import Foundation

/// PFActivity
/// When first created the status is set to opened.
struct ValuePropositionSession {
    enum Status: String, Encodable {
        case opened
        case started
        case paused
        case canceled
        case completed
    }
    private let uuid = UUID()
    var status: Status
    let valueProposition: any ValueProposition
    
    init(valueProposition: any ValueProposition) {
        self.valueProposition = valueProposition
        self.status = .opened
    }
    
    func createRawAnalyticsEvent(action: ValuePropositionAction) -> RawAnalyticsEvent {
        var attributes = AttributesValue()
        attributes["uuid"] = uuid.uuidString
        attributes["status"] = status
        attributes["trigger"] = action.trigger
        attributes["category"] = AnalyticsEventCategory.valueProposition
        for (key, value) in valueProposition.attributes.serialiseToValue() {
            attributes[key] = value
        }
        if let actionAttributes = action.attributes {
            for (key, value) in actionAttributes.serialiseToValue() {
                attributes[key] = value
            }
        }
        return RawAnalyticsEvent(name: valueProposition.name, attributes: attributes)
    }
}
