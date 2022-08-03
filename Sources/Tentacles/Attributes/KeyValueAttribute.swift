//
//  KeyValueAttribute.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

/// Used if attributes do only consist of a single value.
public struct KeyValueAttribute<Value: Encodable>: TentaclesAttributes {
    let key: String
    let value: Value
    public init(key: String, value: Value) {
        self.key = key
        self.value = value
    }
    
    public func serialiseToValue() -> AttributesValue {
        var dic = AttributesValue()
        dic[key] = value as? AnyHashable
        return dic
    }
}
