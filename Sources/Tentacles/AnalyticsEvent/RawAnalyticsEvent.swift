//
//  File.swift
//  
//
//  Created by Patrick Fischer on 23.07.22.
//

import Foundation

/// Event reported to ``AnalyticsReporting``.
public struct RawAnalyticsEvent: Equatable {
    enum Error: Swift.Error {
        case keyNotAvailable
        case attributeValueWrongType
    }
    /// The name of the event being reported.
    public var name: String
    /// Containing all additional attributes that are reported.
    public var attributes: AttributesValue
}

extension RawAnalyticsEvent {
    init(analyticsEvent: AnalyticsEvent<some TentaclesAttributes>) {
        self.name = analyticsEvent.name
        var attributes = AttributesValue()
        attributes[KeyAttributes.trigger] = analyticsEvent.trigger.name
        attributes[KeyAttributes.category] = analyticsEvent.category.name
        let otherAttributeValues = analyticsEvent.otherAttributes.serialiseToValue()
        for (key, value) in otherAttributeValues {
            attributes[key] = value
        }
        self.attributes = attributes
    }
}

public extension RawAnalyticsEvent {
    func getValueAttribute<T>(for key: String) throws -> T {
        let value: AnyHashable = try getValue(in: self.attributes, for: key)
        return try downcast(value)
    }
    
    /// Used to get a value from a dic of type Anyhashable.
    ///
    /// Downcasts a dic of type AnyHashable to [String: AnyHashable], checks for a value of a key in dic
    /// and downcasts to type T. In case dic is not of type AnyHashable it will fail.
    /// Can be used to access nested attributes when transforming ``RawAnalyticsEvent`` with
    /// ``Middleware``.
    ///
    /**
     struct ExampleAttributes: TentaclesAttributes {
         struct Key {
             static let stringProperty: String = "stringProperty"
             static let nestedProperty: String = "nestedProperty"
         }
         struct Nested: Encodable {
             let stringProperty: String
         }
         let stringProperty: String
         let nestedProperty: Nested
     }
     */
    /// Access:
    /**
    ```
     let nestedProperty: [String: AnyHashable] = try event.getValueAttribute(
         for: ExampleAttributes.Key.nestedProperty)
     let nestedStringProperty: String = try event.getValue(in: nestedProperty,
         for: ExampleAttributes.Key.stringProperty)
    ```
    */
    ///
    /// - Parameters:
    ///     -  dic: A dictionary of type AnyHashable
    ///     - key: Key used in dic
    ///
    /// - Returns:
    ///     Value of type T
    /// - Throws: Error.attributeValueWrongType: when the value can not be casted to T.
    /// Error.keyNotAvailable: when the key is not available in the attributes.
    func getValue<T>(in dic: AnyHashable,
                     for key: String) throws -> T {
        let dic: [String: AnyHashable] = try downcast(dic)
        guard let value = dic[key] else {
            throw Error.keyNotAvailable
        }
        return try downcast(value)
    }
    
    /// Downcasts an AnyHashable to concrete type T.
    ///
    ///  - Throws: Error.attributeValueWrongType, when the value can not
    ///  be casted to T.
    func downcast<T>(_ value: AnyHashable) throws -> T {
        guard let typedValue = value as? T else {
            throw Error.attributeValueWrongType
        }
        return typedValue
    }
}
