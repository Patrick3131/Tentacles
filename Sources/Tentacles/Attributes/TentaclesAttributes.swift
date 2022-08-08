//
//  TentacleAttributes.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

/// Attributes used for ``AnalyticsEvent`` and ``ValueProposition``.
///
/// Automatically serialised to ``AttributesValue`` when ``AnalyticsEvent`` or
///``ValueProposition`` are converted to ``RawAnalyticsEvent``.
public protocol TentaclesAttributes: Encodable {
    /// Encodes self in to AttributesValue if it fails to encode self an empty value is returned
    func serialiseToValue() -> AttributesValue
}
public extension TentaclesAttributes {
    func serialiseToValue() -> AttributesValue {
        let data = try? JSONEncoder().encode(self)
        var dic: [String: AnyHashable]?
        if let data {
            dic = try? JSONSerialization.jsonObject(
                with: data, options: []) as? [String: AnyHashable]
        }
        
        return dic ?? [String: AnyHashable]()
    }
}
