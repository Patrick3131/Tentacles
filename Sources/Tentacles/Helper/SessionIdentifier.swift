//
//  SessionIdentifier.swift
//  
//
//  Created by Patrick Fischer on 03.08.22.
//

import Foundation

struct SessionIdentifier: Identifiable {
    private(set) var id: UUID = UUID()
    
    /// sets UUID to a new UUID,
    mutating func reset() {
        id = UUID()
    }
}
