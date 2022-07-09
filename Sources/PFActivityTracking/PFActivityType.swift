//
//  PFActivityType.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

public protocol PFActivityType {
    var name: String { set get }
    var attributes: Attributes { set get }
}
