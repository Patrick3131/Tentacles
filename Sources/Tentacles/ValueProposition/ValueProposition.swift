//
//  PFActivityType.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

public protocol ValueProposition {
    associatedtype Attributes: TentacleAttributes
    var name: String { get }
    var attributes: Attributes { get }
}

public extension ValueProposition {
    func isEqual(to other: any ValueProposition) -> Bool {
        (self.name == other.name)
        && (self.attributes.serialiseToValue() == other.attributes.serialiseToValue())
    }
}
