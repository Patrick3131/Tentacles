//
//  NonFatalErrorTracking.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Ability to report a non fatal error to i.e. a third party service like Crashlytics.
public protocol NonFatalErrorReporting {
    /// Reporting an error and the location the error occurred, the location of occurrence
    /// is represented in filename and the line in the file.
    func report(_ error: Error, filename: String, line: Int)
}
