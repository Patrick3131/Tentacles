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
/// therefore when a  new ValueProposition is tracked by ``ValuePropositionTracking``
/// a new session is created.
public struct ValueProposition<Attributes: TentaclesAttributes> {
    public let name: String
    public let attributes: TentaclesAttributes
    public init(name: String, attributes: Attributes) {
        self.name = name
        self.attributes = attributes
    }
}
