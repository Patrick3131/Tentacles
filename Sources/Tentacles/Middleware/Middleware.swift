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
        /// transformed. If the item was not transformed it sill needs to be forwarded otherwise it will be
        /// ignored.
        case forward(Item)
        /// Item will be skipped by the consumer of the ``Middleware``.
        case skip
    }
    let closure: (Item) -> Action
    /// Used to transform an Item, use cases range from adding data, editing or ignoring
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
    
    /// ``Middleware`` to calculate the duration between two status of ``ValuePropositionAction`` related to a ``ValueProposition``.
    ///
    /// ``RawAnalyticsEvent``s that will be transformed need to be of category
    ///  valueProposition, and need to be derived by a ``ValueProposition`` that
    ///  has been affected by a ``ValuePropositionAction`` with both status.
    ///  If successful transformed a new duration attribute with a Double will be added
    ///  to the attributes.
    ///
    /**
     calculateValuePropositionDuration(
         between: .open,
         and: .completed)
     */
    /// In case of a successful transformation this would add a double value with **durationOpenedCompleted** as a key to the the attributes of ``RawAnalyticsEvent``.
    static func calculateValuePropositionDuration(
        between status: ValuePropositionAction.Status,
        and otherStatus: ValuePropositionAction.Status)
    -> Self {
        return Self { event -> Action in
            do {
                let category: String = try event.getValueAttribute(
                    for: KeyAttributes.category)
                if category == TentaclesEventCategory.valueProposition.rawValue {
                    let statusValue: Double = try event.getValueAttribute(
                        for: status.derivedAttributesKey)
                    let otherStatusValue: Double = try event.getValueAttribute(
                        for: otherStatus.derivedAttributesKey)
                    var newEvent = event
                    let duration = otherStatusValue - statusValue
                    let key = "duration\(status.derivedAttributesKey.capitalized)\(otherStatus.derivedAttributesKey.capitalized)"
                    newEvent.attributes[key] = duration
                    return .forward(newEvent)
                }
                return .forward(event)
            } catch {
                print(error.localizedDescription)
                return .forward(event)
            }
        }
    }

    static func skipEvent(for category: AnalyticsEventCategory)
    -> Self {
        return Self { event -> Action in
            do {
                let categoryValue: String = try event.getValueAttribute(
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
    
    static func skipEvent(for names: [String]) -> Self {
        return Self { event -> Action in
            names.contains(event.name) ? .skip : .forward(event)
        }
    }
}

fileprivate extension ValuePropositionAction.Status {
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
