//
//  NonFatalErrorTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public protocol NonFatalErrorReporting {
    func report(_ error: Error, filename: String, line: Int)
}
