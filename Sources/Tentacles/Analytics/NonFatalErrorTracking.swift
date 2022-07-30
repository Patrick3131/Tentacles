//
//  NonFatalErrorTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol NonFatalErrorTracking {
    func track(_ error: Error)
}
