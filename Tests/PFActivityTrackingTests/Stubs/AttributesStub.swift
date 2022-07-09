//
//  AttributesStub.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation
import PFActivityTracking

struct AttributesStub: Attributes {
    let _values: [String: AnyHashable]
    init(values: [String: AnyHashable]) {
        self._values = values
    }
    var value: AttributesValue {
        return _values
    }
}
