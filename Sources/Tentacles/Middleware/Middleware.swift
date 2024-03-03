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
        return self.reduce(event) { (currentEvent, middleware) in
            return currentEvent.flatMap(middleware.transform)
        }
    }
}

extension String {
    /// Converts a camelCase string to snake_case.
    func camelCaseToSnakeCase() -> String {
        return unicodeScalars.reduce("") { partialResult, scalar in
            if CharacterSet.uppercaseLetters.contains(scalar) {
                // Convert scalar to String before calling lowercased().
                let lowercasedChar = String(scalar).lowercased()
                // Prepend "_" before uppercase letters (except for the first character).
                return partialResult + (partialResult.isEmpty ? "" : "_") + lowercasedChar
            } else {
                return partialResult + String(scalar)
            }
        }
    }
}
