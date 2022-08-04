//
//  ValuePropositionTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol ValuePropositionTracking {
    func track(_ valueProposition: any ValueProposition,
                with action: ValuePropositionAction)
}
