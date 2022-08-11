//
//  RawDomainActivity.swift
//  
//
//  Created by Patrick Fischer on 04.08.22.
//

import Foundation

/// Represents a raw type of ``DomainActivity`` to store internally to keep attributes for
/// ``DomainActivity`` type safe.
struct RawDomainActivity: Equatable {
    
    let name: String
    let attributes: TentaclesAttributes
    
    init(from domainActivity: DomainActivity<some TentaclesAttributes>) {
        self.name = domainActivity.name
        self.attributes = domainActivity.attributes
    }
    
    static func == (lhs: RawDomainActivity, rhs: RawDomainActivity) -> Bool {
        let lhsAttributeValue = try? lhs.attributes.serialiseToValue()
        let rhsAttributeValue = try? rhs.attributes.serialiseToValue()
        return (lhs.name == rhs.name)
        && (lhsAttributeValue == rhsAttributeValue)
    }
}
