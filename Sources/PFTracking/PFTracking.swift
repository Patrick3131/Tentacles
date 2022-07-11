//
//  PFTracking.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation


public protocol PFTracking {
    func identifyUser(with id: String)
    func track(_ event: Event)
}
