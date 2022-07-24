//
//  PFActivityManagerTracking.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation
import Combine

/// This class manages the activities and provides a publisher to communicate activities with changed status, consumer is usually a Tracking .
///
/// More than one Activity of different **ValuePropositions** can be managed at once.
/// However, not more than one that are the equal. If the equal ValueProposition is added again with a status that is not allowed it will update to the most recent activity.
/// After the status of an Activity changed to cancelled or completed it will be removed from the managed Activities and then forwarded to PFTracking.
/// If an activity is not available and not added with the initial open value it will automatically forward previous necessary states.
/// i.e. added with completed state: will forward open, started and  completed.
/// added with paused state: will forward open, started and paused.
/// added with started will forward open and started.
/// added with cancelled will forward open and cancelled.
///
/// Discussion about adding additional attributes via status to the tracking event later on in the lifecycle of the Activity:
/// it doesnt make sense to add them to the activity itself, because then the attributes are also added to later events i.e to completed even if they were only supposed to be used for paused. So if they are going to be added then via the status enum.
class ValuePropositionSessionManager {
    enum Error: Swift.Error {
        case initialActionNeedsToBeOpen
        case prohibitedStateUpdate(session: ValuePropositionSession,
                                   action: ValuePropositionAction.Status)
    }
    
    private var sessions = [ValuePropositionSession]()

    func process(for valueProposition: some ValueProposition,
                       with action: ValuePropositionAction) throws -> RawAnalyticsEvent {
        if let index = getFirstIndexEqualSession(for: valueProposition) {
            return try processActiveSession(for: action,
                                            at: index).createRawAnalyticsEvent(action: action)
        } else {
            return try createInitialSession(for: valueProposition,
                                            and: action).createRawAnalyticsEvent(action: action)
        }
    }
    
    private func processActiveSession(for action: ValuePropositionAction,
                                      at index: Int) throws -> ValuePropositionSession {
        var session = sessions[index]
        let newStatus = try createStatus(from: session, and: action.status)
        session.status = newStatus
        refreshSessions(session: session, index: index)
        return session
    }
    
    private func createInitialSession(for valueProposition: any ValueProposition,
                                      and action: ValuePropositionAction) throws -> ValuePropositionSession {
        if action.status == .open {
            let newSession = ValuePropositionSession(valueProposition: valueProposition)
            sessions.append(newSession)
            return newSession
        } else {
            throw Error.initialActionNeedsToBeOpen
        }
    }
    
    private func refreshSessions(session: ValuePropositionSession, index: Int) {
        switch session.status {
        case .opened, .started, .paused:
            sessions[index] = session
        case .canceled, .completed :
            sessions.remove(at: index)
        }
    }
    
    private func getFirstIndexEqualSession(for valueProposition: any ValueProposition) -> Int? {
        sessions.firstIndex { valueProposition.isEqual(to: $0.valueProposition) }
    }
    
    private func createStatus(from session: ValuePropositionSession,
                              and actionStatus: ValuePropositionAction.Status) throws
    -> ValuePropositionSession.Status {
        switch (session.status, actionStatus) {
        case (.opened, .open):
            return .opened
        case (.opened, .start):
            return .started
        case (.opened, .cancel), (.started, .cancel),(.paused, .cancel):
            return .canceled
        case (.started, .pause):
            return .paused
        case (.started, .complete):
            return .completed
        case (.paused, .start):
            return .started
        default:
            throw Error.prohibitedStateUpdate(
                session: session, action: actionStatus)
        }
    }
}
