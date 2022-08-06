//
//  ValuePropositionStub.swift
//  
//
//  Created by Patrick Fischer on 06.08.22.
//

import Foundation
import Tentacles

typealias ValuePropositionStub = ValueProposition<TentaclesAttributesStub>

extension ValuePropositionStub {
    static let name = "Value Proposition Stub"
    init(name: String = ValuePropositionStub.name,
         _attributes: TentaclesAttributesStub = TentaclesAttributesStub()) {
        self.init(name: name, attributes: _attributes)
    }
}
