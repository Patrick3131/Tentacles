//
//  EmptyAttributes.swift
//  
//
//  Created by Patrick Fischer on 03.08.22.
//

import Foundation

/// Used if no attributes are necessary for ``AnalyticsEvent``or
/// ``DomainActivity``.
public struct EmptyAttributes: TentaclesAttributes {
    public init() {}
}
