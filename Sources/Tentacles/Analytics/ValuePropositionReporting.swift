//
//  ValuePropositionTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol ValuePropositionReporting {
    func report(for valueProposition: any ValueProposition,
                with action: ValuePropositionAction)
}
