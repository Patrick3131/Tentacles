//
//  RawValueProposition.swift
//  
//
//  Created by Patrick Fischer on 04.08.22.
//

import Foundation

/// Represents a raw type of ``ValueProposition`` to store internally to keep Attributes for
/// ``ValueProposition`` type safe
struct RawValueProposition {
    let name: String
    let attributes: TentaclesAttributes
    
    init(valueProposition: ValueProposition<some TentaclesAttributes>) {
        self.name = valueProposition.name
        self.attributes = valueProposition.attributes
    }
    
    func isEqual(to other: RawValueProposition) -> Bool {
        (self.name == other.name)
        && (self.attributes.serialiseToValue() == other.attributes.serialiseToValue())
    }
}
