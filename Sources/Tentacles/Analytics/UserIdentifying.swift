//
//  UserIdentifying.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

/// Ability to identify a user.
public protocol UserIdentifying {
    associatedtype Attributes
    /// Identifies a user for tracking.
    /// - Parameters:
    ///     -   id: The user id associated to the user.
    func identify(with id: String)
    /// Resets the identity of a user.
    func logout()
    func addUserAttributes(_ attributes: Attributes)
}
