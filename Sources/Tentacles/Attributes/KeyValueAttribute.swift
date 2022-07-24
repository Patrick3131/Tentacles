//
//  KeyValueAttribute.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

public struct KeyValueAttribute<Value: Encodable>: TentacleAttributes {
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
