/*
 Activity is a process of a user that will be tracked.
 It needs to be identifiable.
 It has a status Options (open, start, paused?, cancelled, completed)
 It has attributes
 */
import Foundation

/// PFActivity
/// When first created the status is set to opened.
struct ValuePropositionSession: AnalyticsEvent {
    struct Attributes: AnalyticsEventAttributes, Encodable {
        let uuid: String
        let status: Status
        let valuePropostionAttributes: AttributesValue
        
        enum CodingKeys: String, CodingKey {
            case uuid, status, valuePropostionAttributes
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(uuid, forKey: .uuid)
            try container.encode(status, forKey: .status)
            let data = try JSONSerialization.data(withJSONObject: valuePropostionAttributes, options: [])
            try container.encode(data, forKey: .valuePropostionAttributes)
            
        }
    }
    
    enum Status: String, Encodable {
        case opened
        case started
        case paused
        case canceled
        case completed
    }
    
    var trigger: AnalyticsEventTrigger
    var status: Status
    let valueProposition: ValueProposition
    let category: AnalyticsEventCategory = .valueProposition
    let uuid = UUID()
    
    var name: String {
        valueProposition.name
    }
    
    var otherAttributes: Attributes? {
        Attributes(uuid: uuid.uuidString,
                   status: .canceled,
                   valuePropostionAttributes: valueProposition.attributes.serialiseToValue())
    }
    
    init(valueProposition: ValueProposition,
         action: AnalyticsEventTrigger) {
        self.valueProposition = valueProposition
        self.status = .opened
        self.trigger = action
    }
}
