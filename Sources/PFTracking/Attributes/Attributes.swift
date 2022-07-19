//
//  Attributes.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

public protocol PFAttributes: Encodable {
    /// Encodes self in to AttributesValue if it fails to encode self an empty value is returned
    func serialiseToValue() -> AttributesValue
}
public extension PFAttributes {
    func serialiseToValue() -> AttributesValue {
        let data = try? JSONEncoder().encode(self)
        let dic = try? JSONSerialization.jsonObject(
            with: data!, options: .fragmentsAllowed) as? [String: AnyHashable]
        return dic ?? [String: AnyHashable]()
    }
}
