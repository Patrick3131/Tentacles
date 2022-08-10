//
//  Serialisable.swift
//  
//
//  Created by Patrick Fischer on 10.08.22.
//

import Foundation

/// Being able to be serialised, making the entity consumable by an ``AnalyticsReporting`` entity.
public protocol Serialisable {
    /// Self is serialised to ``AttributesValue``.
    ///
    /// Making self amenable to be consumed by an ``AnalyticsReporting``
    /// entity.
    func serialiseToValue() throws -> AttributesValue
}
