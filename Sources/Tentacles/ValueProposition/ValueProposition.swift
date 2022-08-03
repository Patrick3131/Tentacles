//
//  PFActivityType.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

/// Describes domain relevant activities that are in great importance for analytics.
/// It describes the core functionalities the user interacts with while using the app.
///
/// It is assumed that the user devotes a session to a particular ValueProposition,
/// therefore when a  new ValueProposition is tracked by ``ValuePropositionReporting``
/// a new session is created.
public protocol ValueProposition {
    associatedtype Attributes: TentaclesAttributes
    var name: String { get }
    var attributes: Attributes { get }
}

public extension ValueProposition {
    func isEqual(to other: any ValueProposition) -> Bool {
        (self.name == other.name)
        && (self.attributes.serialiseToValue() == other.attributes.serialiseToValue())
    }
}
