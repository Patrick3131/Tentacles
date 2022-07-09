/*
 Activity is a process of a user that will be tracked.
 It needs to be identifiable.
 It has a status Options (open, start, paused?, cancelled, completed)
 It has attributes
 */
import Foundation


public struct PFActivity {
    public enum Status: String {
        case opened
        case started
        case paused
        case cancelled
        case completed
    }
    
    public let uuid = UUID()
    public let type: PFActivityType
    public var status: Status
    
    public init(type: PFActivityType, status: Status) {
        self.type = type
        self.status = status
    }
    
    public var attributesValue: AttributesValue {
        var values = type.attributes.value
        let _lacyValuesDic = lazyAttributes
            .reduce([String: AnyHashable](), { (dict, new) in
                var nextDict = dict
                nextDict.combine(new.value)
                return nextDict
            })
        values.combine(_lacyValuesDic)
        values["UUID"] = uuid.uuidString
        return values
    }
    
    /// attributes that are added during the lifecycle
    private var lazyAttributes = [Attributes]()
    
    /// adds new Attributes, if a key already exists the latest will be used
    public mutating func addAttributes(_ attributes: Attributes) {
        lazyAttributes.append(attributes)
    }
}

private extension Dictionary {
    mutating func combine(_ dic: Self) {
        self.merge(dic) { (_ , new) in new }
    }
}




