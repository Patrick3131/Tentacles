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
        ///
        /// If the item was not transformed it still needs to be forwarded otherwise it will be
        /// skipped.
        case forward(Item)
        /// Item will be skipped by the consumer of the ``Middleware``.
        case skip
    }
    private let closure: (Item) -> Action
    /// Used to transform an Item, use cases range from adding data, editing or ignoring
    /// the Item.
    /// - Returns: ``Action``, if the returned value is skip then it will be ignored by the reporting
    public init(_ closure: @escaping (Item) -> Action) {
        self.closure = closure
    }
    
    /// Transforms item by applying closure to it.
    ///
    ///- Returns: Nil if the action evaluates to skip. Otherwise the transformed item will be returned.
    func transform(_ item: Item?) -> Item? {
        guard let item = item else { return nil }
        let action = closure(item)
        switch action {
        case .forward(let item): return item
        case .skip: return nil
        }
    }
}

public extension Array where Array.Element == Middleware<RawAnalyticsEvent> {
    /// Transforms event by applying ``Middleware``s to it.
    ///
    /// - Returns: Nil if the actions evaluated to skip.
    /// Otherwise will returned the transformed ``RawAnalyticsEvent``.
    func transform(_ event: RawAnalyticsEvent?) -> RawAnalyticsEvent? {
        var _newEvent: RawAnalyticsEvent? = event
        self.forEach { middleware in
            if let unwrappedEvent = _newEvent {
                _newEvent = middleware.transform(unwrappedEvent)
            }
        }
        return _newEvent
    }
}

public extension Middleware where Item == RawAnalyticsEvent {
    /// ``Middleware`` to capitalise the keys of all attributes for a ``RawAnalyticsEvent`
    static let capitalisedAttributeKeys = Self { event -> Action in
        var attributes = AttributesValue()
        event.attributes.forEach {
            attributes[$0.key.capitalized] = $0.value
        }
        return .forward(RawAnalyticsEvent(name: event.name, attributes: attributes))
    }
    
    /// ``Middleware`` to calculate the duration between two status of ``DomainActivityAction`` related to a ``DomainActivity``.
    ///
    /// ``RawAnalyticsEvent``s that will be transformed need to be of category
    ///  domainActivity, and need to be derived by a ``DomainActivity`` that
    ///  has been affected by a ``DomainActivityAction`` with both status.
    ///  If successful transformed a new duration attribute with a Double will be added
    ///  to the attributes.
    ///
    /**
     calculateDomainActivityDuration(
         between: .open,
         and: .completed)
     */
    /// In case of a successful transformation this would add a double value with **durationOpenedCompleted** as a key to the the attributes of ``RawAnalyticsEvent``.
    static func calculateDomainActivityDuration(
        between status: DomainActivityAction.Status,
        and otherStatus: DomainActivityAction.Status)
    -> Self {
        return Self { event -> Action in
            do {
                let category: String = try event.getAttributeValue(
                    for: KeyAttributes.category)
                if category == TentaclesEventCategory.domainActivity.rawValue {
                    let statusValue: Double = try event.getAttributeValue(
                        for: status.derivedAttributesKey)
                    let otherStatusValue: Double = try event.getAttributeValue(
                        for: otherStatus.derivedAttributesKey)
                    var newEvent = event
                    let duration = otherStatusValue - statusValue
                    let key = "duration\(status.derivedAttributesKey.capitalized)\(otherStatus.derivedAttributesKey.capitalized)"
                    newEvent.attributes[key] = duration
                    return .forward(newEvent)
                }
                return .forward(event)
            } catch {
                return .forward(event)
            }
        }
    }

    /// Skips event that matches a category.
    ///
    /// - Parameter category: Category of the event that will be skipped.
    static func skipEvent(for category: AnalyticsEventCategory)
    -> Self {
        return Self { event -> Action in
            do {
                let categoryValue: String = try event.getAttributeValue(
                    for: KeyAttributes.category)
                if categoryValue == category.name {
                    return .skip
                }
                return .forward(event)
            } catch {
                return .forward(event)
            }
        }
    }
    
    /// Skips event that matches a name provided with names.
    ///
    /// - Parameter names: Names of the event that will be skipped.
    static func skipEvent(for names: [String]) -> Self {
        return Self { event -> Action in
            names.contains(event.name) ? .skip : .forward(event)
        }
    }
}

fileprivate extension DomainActivityAction.Status {
    var derivedAttributesKey: String {
        switch self {
        case .open: return "opened"
        case .start: return "started"
        case .pause: return "paused"
        case .cancel: return "canceled"
        case .complete: return "completed"
        }
    }
}
