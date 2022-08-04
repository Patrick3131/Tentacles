//
//  PFActivityType.swift
//  
//
//  Created by Patrick Fischer on 09.07.22.
//

import Foundation

/// Describes a reason why a user would choose your app.
///
/// ``ValueProposition``s describe the core functionalities the user interacts with while using the app.
/// It is of great importance and therefore should get special attention.
///
/// It is assumed that the user devotes a time duration to a particular ValueProposition,
/// therefore when a ValueProposition is initially tracked by ``ValuePropositionTracking``
/// a new session (identified by UUID) is created.
/// The session and its UUID is managed internally by Tentacles.
///
/// This brings the advantage of further possibilities to analyse the data, as connections between the events can be derived.
/// For example as ``Tentacles`` tracks every status change of a session with a timestamp
/// it is easily possible to calculate the duration between the ``ValueProposition`` started and completed.
///
/// When a ``ValueProposition`` is tracked with an ``ValuePropositionAction``, the status of the session is
/// updated and a ``RawAnalyticsEvent`` generated and forwarded. Status changes that are allowed:
///
///```mermaid
/// Open --> Start
/// Open --> Cancel
/// Start --> Pause
/// Start --> Complete
/// Start --> Cancel
/// Pause --> Start
/// Pause --> Cancel
///```
/// By reaching completed or canceled the session ends and it gets deallocated.
/// If a prohibited status update occurs a non fatal error event is forwarded and the status is **not** updated.
/// In cases where attributes are specific to a session status they can be
/// added to the ``ValuePropositionAction``. I.e. if a pause event needs the pausing point of the video,
/// these attributes are then mapped to the generated ``RawAnalyticsEvent``s.
///
/// Multiple sessions with different ValuePropositions can be managed. However, only one session for one particular ``ValueProposition``.
/// A ``ValueProposition`` is equal if name and attributes match, not considering additional attributes that can be added by ``ValuePropositionAction``.
///
/// When the app **will resign**, all active ``ValueProposition`` sessions are canceled and cached in memory
/// in case the app enters foreground again. After app **did become active** again, all previous active
/// sessions are reset and updated with a new identifier. For all previous active sessions an open event
/// is sent and then reset to the previous status that also triggers an event.
public struct ValueProposition<Attributes: TentaclesAttributes> {
    public let name: String
    /// Attributes that are relevant to the ``ValueProposition``.
    public let attributes: TentaclesAttributes
    
    public init(name: String, attributes: Attributes) {
        self.name = name
        self.attributes = attributes
    }
}
