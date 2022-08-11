//
//  Serialisable.swift
//  
//
//  Created by Patrick Fischer on 10.08.22.
//

import Foundation

/// Being able to be serialised, making the entity consumable by an ``AnalyticsReporting`` entity.
public protocol Serialisable: Encodable {
    /// Self is serialised to ``AttributesValue``.
    ///
    /// Making self amenable to be consumed by an ``AnalyticsReporting``
    /// entity.
    ///
    /// - Throws: Throws if self can't be serialised, this could be because of encoding issues i.e.
    /// encoding is not correctly implemented.
    func serialiseToValue() throws -> AttributesValue
}

fileprivate enum SerialisableError: Error {
    case downcastingToDictionaryFailed(value: Any)
}

public extension Serialisable {
    func serialiseToValue() throws -> AttributesValue {
        let data = try JSONEncoder().encode(self)
        let dic = try JSONSerialization.jsonObject(
            with: data, options: [])
        guard let dic = dic as? [String: AnyHashable] else {
            throw SerialisableError.downcastingToDictionaryFailed(
                value: dic)
        }
        return dic
    }
}
