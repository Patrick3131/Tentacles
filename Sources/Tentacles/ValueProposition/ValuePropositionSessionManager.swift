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
        case selfWasNil
    }
    private let _eventPublisher: PassthroughSubject<Result<RawAnalyticsEvent, Swift.Error>, Never> = .init()
    lazy var eventPublisher = _eventPublisher.eraseToAnyPublisher()
    
    private var sessions = [ValuePropositionSession]()
    private let lock = NSLock()

    func process(for valueProposition: some ValueProposition,
                 with action: ValuePropositionAction) {
        lock.lock()
            do {
                let session: ValuePropositionSession
                if let index = getFirstIndexSimilarValueProposition(as: valueProposition) {
                    session = try processActiveSession(for: action,
                                                           at: index)
                } else {
                    session = try initialiseSession(for: valueProposition,
                                                        and: action)
                }
                publishEvent(for: session, with: action)
            } catch {
                publish(error)
            }
        lock.unlock()
    }
    
    private func processActiveSession(for action: ValuePropositionAction,
                                      at index: Int) throws -> ValuePropositionSession {
        var session = sessions[index]
        let newStatus = try createStatus(from: session, and: action.status)
        session.status = newStatus
        update(session, index: index)
        return session
    }
    
    private func initialiseSession(for valueProposition: any ValueProposition,
                                   and action: ValuePropositionAction)
    throws -> ValuePropositionSession {
        if action.status == .open {
            let newSession = ValuePropositionSession(
                valueProposition: valueProposition)
            sessions.append(newSession)
            return newSession
        } else {
            throw Error.initialActionNeedsToBeOpen
        }
    }
    
    private func update(_ session: ValuePropositionSession, index: Int) {
        switch session.status {
        case .opened, .started, .paused:
            sessions[index] = session
        case .canceled, .completed:
            sessions.remove(at: index)
        }
    }
    
    private func getFirstIndexSimilarValueProposition(as valueProposition: any ValueProposition) -> Int? {
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
    
    private func publish(_ error: Swift.Error) {
        _eventPublisher.send(.failure(error))
    }
    
    private func publishEvent(for session: ValuePropositionSession,
                              with action: ValuePropositionAction) {
        _eventPublisher.send(.success(
            session.createRawAnalyticsEvent(action: action)))
    }
    
    private func publishEvent(for session: ValuePropositionSession,
                              with trigger: TentaclesEventTrigger) {
        _eventPublisher.send(.success(
            session.createRawAnalyticsEvent(trigger: trigger)))
    }
    
    //MARK: Background & Foreground Applifecycle
    
    /// Sessions before app went in to background, will be used to reset sessions in case
    /// app enters foreground again.
    private var cachedSessions = [ValuePropositionSession]()

    /// When the app will resign, all active sessions are canceled and cached in memory in case
    /// the app enters foreground again.
    func processWillResign() {
        lock.lock()
        cachedSessions = sessions
        for (index, session) in sessions.enumerated() {
            var newSession = session
            newSession.status = .canceled
            update(newSession, index: index)
            publishEvent(for: newSession,
                         with: TentaclesEventTrigger.willResignActive)
        }
        lock.unlock()
    }
    
    /// After app did become active again, all previous active sessions are reset and updated with a new identifier.
    /// For all previous active sessions an open event is sent and then reset to the previous status.
    func processDidBecomeActive() {
        lock.lock()
        var newSessions = cachedSessions
        newSessions.enumerated().forEach { (index, _ ) in
            newSessions[index].reset()
            newSessions[index].status = .opened
            publishEvent(for: newSessions[index],
                         with: TentaclesEventTrigger.didEnterForeground)
            newSessions[index].status = cachedSessions[index].status
            publishEvent(for: newSessions[index],
                         with: TentaclesEventTrigger.didEnterForeground)
        }
        self.sessions = newSessions
        cachedSessions = []
        lock.unlock()
    }
}
