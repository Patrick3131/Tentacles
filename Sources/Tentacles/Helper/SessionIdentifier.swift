//
//  SessionIdentifier.swift
//  
//
//  Created by Patrick Fischer on 03.08.22.
//

import Foundation

/// Entity to manage an identity of a session, used in ``Tentacles``
/// and ``ValuePropositionSession``.
struct SessionIdentifier: Identifiable {
    private(set) var id: UUID = UUID()
    
    /// sets UUID to a new UUID,
    mutating func reset() {
        id = UUID()
    }
}
