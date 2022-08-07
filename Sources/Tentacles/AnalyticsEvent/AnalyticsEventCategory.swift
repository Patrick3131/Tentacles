//
//  AnalyticsEventCategory.swift
//  
//
//  Created by Patrick Fischer on 18.07.22.
//

import Foundation

/// Used to categorise ``AnalyticsEvent``, a category could be i.e. lifecycle, interaction
/// or value proposition,.
///
/// Needs to be defined by the app.
/// ``TentaclesEventCategory`` offers default cases that can be used.
/// When ``AnalyticsEvent`` is converted to ``RawAnalyticsEvent`` category will be added
/// as an attribute.
public protocol AnalyticsEventCategory {
    var name: String { get }
}
