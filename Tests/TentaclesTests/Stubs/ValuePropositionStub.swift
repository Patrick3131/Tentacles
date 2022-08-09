//
//  DomainActivityStub.swift
//  
//
//  Created by Patrick Fischer on 06.08.22.
//

import Foundation
import Tentacles

typealias DomainActivityStub = DomainActivity<TentaclesAttributesStub>

extension DomainActivityStub {
    static let name = "Value Proposition Stub"
    init(name: String = DomainActivityStub.name,
         _attributes: TentaclesAttributesStub = TentaclesAttributesStub()) {
        self.init(name: name, attributes: _attributes)
    }
}
