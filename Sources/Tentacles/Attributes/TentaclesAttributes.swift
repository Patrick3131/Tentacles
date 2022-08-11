//
//  TentacleAttributes.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

/// Attributes used for ``AnalyticsEvent`` and ``DomainActivity``.
///
/// Automatically serialised to ``AttributesValue`` when ``AnalyticsEvent`` or
///``DomainActivity`` are converted to ``RawAnalyticsEvent``.
public protocol TentaclesAttributes: Serialisable {}

