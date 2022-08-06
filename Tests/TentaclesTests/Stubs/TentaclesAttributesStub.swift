//
//  TestAttributesStub.swift
//  
//
//  Created by Patrick Fischer on 06.08.22.
//

import Foundation
import Tentacles

struct TentaclesAttributesStub: TentaclesAttributes {
    struct Key {
        static let stringProperty: String = "stringProperty"
        static let doubleProperty: String = "doubleProperty"
        static let boolProperty: String = "boolProperty"
        static let enumProperty: String = "enumProperty"
        static let nestedProperty: String = "nestedProperty"
    }
    static let stringPropertyValue = "stringProperty"
    static let doublePropertyValue: Double = 123.0
    static let boolPropertyValue: Bool = true
    static let enumPropertyValue: EnumTest = .testCase
    static let nestedPropertyValue: Nested = .init()
    struct Nested: Encodable {
        let stringProperty: String
        let doubleProperty: Double
        let boolProperty: Bool
        
        static let stringPropertyValue = "stringProperty"
        static let doublePropertyValue: Double = 123.0
        static let boolPropertyValue: Bool = true
        
        init(stringProperty: String = TentaclesAttributesStub.stringPropertyValue,
             doubleProperty: Double = TentaclesAttributesStub.doublePropertyValue,
             boolProperty: Bool = TentaclesAttributesStub.boolPropertyValue) {
            self.stringProperty = stringProperty
            self.doubleProperty = doubleProperty
            self.boolProperty = boolProperty
        }
    }
    enum EnumTest: String, Encodable {
        case testCase
        case otherTestCase
    }
    let stringProperty: String
    let doubleProperty: Double
    let boolProperty: Bool
    let enumProperty: EnumTest
    let nestedProperty: Nested
    init(stringProperty: String = TentaclesAttributesStub.stringPropertyValue,
         doubleProperty: Double = TentaclesAttributesStub.doublePropertyValue,
         boolProperty: Bool = TentaclesAttributesStub.boolPropertyValue,
         enumProperty: EnumTest = TentaclesAttributesStub.enumPropertyValue,
         nestedProperty: Nested = TentaclesAttributesStub.nestedPropertyValue) {
        self.stringProperty = stringProperty
        self.doubleProperty = doubleProperty
        self.boolProperty = boolProperty
        self.enumProperty = enumProperty
        self.nestedProperty = nestedProperty
    }
}
