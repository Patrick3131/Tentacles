//
//  RawValueProposition.swift
//  
//
//  Created by Patrick Fischer on 04.08.22.
//

import Foundation

/// Represents a raw type of ``ValueProposition`` to store internally to keep attributes for
/// ``ValueProposition`` type safe.
struct RawValueProposition: Equatable {
    
    let name: String
    let attributes: TentaclesAttributes
    
    init(from valueProposition: ValueProposition<some TentaclesAttributes>) {
        self.name = valueProposition.name
        self.attributes = valueProposition.attributes
    }
    
    static func == (lhs: RawValueProposition, rhs: RawValueProposition) -> Bool {
        (lhs.name == rhs.name)
        && (lhs.attributes.serialiseToValue() == rhs.attributes.serialiseToValue())
    }
}
