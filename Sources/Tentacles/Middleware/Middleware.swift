//
//  Middleware.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

/// Middleware to transform an Item or skip it.
///
/// Middleware where Item == ``RawAnalyticsEvent`` can be registered via ``AnalyticsRegister``
/// to a specific ``AnalyticsReporting`` entity or be universally used for all reporters.
public struct Middleware<Item> {
    /// Action to forward an Item or skip it.
    public enum Action {
        /// Item will be forwarded by the consumer of the ``Middleware``, usually after it has been
        /// transformed.
        case forward(Item)
        /// Item will be skipped by the consumer of the ``Middleware``.
        case skip
    }
    let closure: (Item) -> Action
    /// Used to transform an Item, usecases range from adding data, editing or ignoring
    /// the Item.
    /// - Returns: ``Action``, if the returned value is skip then it will be ignored by the reporting
    public init(_ closure: @escaping (Item) -> Action) {
        self.closure = closure
    }
}

public extension Middleware where Item == RawAnalyticsEvent {
    /// ``Middleware`` to capitalise the keys of all attributes for a ``RawAnalyticsEvent`
    static let capitalisedAttributeKeys: Self = Self { event -> Action in
        var attributes = AttributesValue()
        event.attributes.forEach {
            attributes[$0.key.capitalized] = $0.value
        }
        return .forward(RawAnalyticsEvent(name: event.name, attributes: attributes))
    }
}
