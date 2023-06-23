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
        case keyNotAvailable(String)
        case attributeValueWrongType(Any, Any)
        case valueIsNotData(AnyHashable)
    }

    /// The name of the event being reported.
    public var name: String
    /// Containing all additional attributes that are reported.
    public var attributes: AttributesValue
}

extension RawAnalyticsEvent {
    init(analyticsEvent: AnalyticsEvent<some TentaclesAttributes>) throws {
        self.name = analyticsEvent.name
        var attributes = AttributesValue()
        attributes[KeyAttributes.trigger] = analyticsEvent.trigger.name
        attributes[KeyAttributes.category] = analyticsEvent.category.name
        let otherAttributeValues = try analyticsEvent.otherAttributes.serialiseToValue()
        for (key, value) in otherAttributeValues {
            attributes[key] = value
        }
        self.attributes = attributes
    }
}

public extension RawAnalyticsEvent {
    /// Checks if the `RawAnalyticsEvent` belongs to a specific category.
    ///
    /// This function attempts to decode the value for the 'category' attribute in
    /// the event's attributes dictionary, and then compares it to the name of the
    /// provided category.
    ///
    /// - Parameter category: The category to compare with the event's category.
    ///
    /// - Returns: `true` if the event belongs to the provided category, `false` otherwise.
    func isCategory(_ category: AnalyticsEventCategory) -> Bool {
        do {
            let categoryValue: String = try decodeValue(for: KeyAttributes.category)
            return category.name == categoryValue
        } catch {
            return false
        }
    }

    /// Returns attribute value of key of attributes in ``RawAnalyticsEvent``.
    func getAttributeValue<T>(for key: String) throws -> T {
        let value: AnyHashable = try getValue(in: self.attributes, for: key)
        return try RawAnalyticsEvent.downcast(value)
    }

    /// Decodes a value of type T from the attributes dictionary of a ``RawAnalyticsEvent``.
    ///
    /// This function first downcasts the attributes dictionary of the RawAnalyticsEvent to [String: AnyHashable] and
    /// retrieves the Data value for the provided key. Then, it uses a JSONDecoder
    /// to decode the Data into the desired type T, conforming to the Decodable protocol.
    ///
    /// - Parameter key: Key used in the attributes dictionary to retrieve the Data value.
    ///
    /// - Returns:
    ///   The decoded value of type T.
    ///
    /// - Throws:
    ///   Error.keyNotAvailable: when the key is not available in the attributes dictionary.
    ///   Decoding errors: when the decoding process fails.
    func decodeValue<T: Decodable>(for key: String) throws -> T {
        // Downcast the dictionary to [String: AnyHashable]
        let dic: [String: AnyHashable] = try RawAnalyticsEvent.downcast(self.attributes)

        guard let value = dic[key] else {
            throw Error.keyNotAvailable(key)
        }

        if let downcastedValue = value as? T {
            return downcastedValue
        }
        // Get the value for the key as Data
        guard let dataValue = value as? Data else {
            throw Error.valueIsNotData(value)
        }

        // Use a JSONDecoder to decode the Data to the desired type T
        return try JSONDecoder().decode(T.self, from: dataValue)
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
     let nestedProperty: [String: AnyHashable] = try event.getAttributeValue(
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
        let dic: [String: AnyHashable] = try RawAnalyticsEvent.downcast(dic)
        guard let value = dic[key] else {
            throw Error.keyNotAvailable(key)
        }
        return try RawAnalyticsEvent.downcast(value)
    }
    
    /// Downcasts an AnyHashable to concrete type T.
    ///
    ///  - Throws: Error.attributeValueWrongType, when the value can not
    ///  be casted to T.
    internal static func downcast<T>(_ value: AnyHashable) throws -> T {
        guard let typedValue = value as? T else {
            throw Error.attributeValueWrongType(value.self, T.self)
        }
        return typedValue
    }
}
