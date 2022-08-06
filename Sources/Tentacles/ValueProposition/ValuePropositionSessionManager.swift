//
//  PFActivityManagerTracking.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation
import Combine

/// Manages sessions of ``ValueProposition``s.
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
    
    /// Processes a ``ValueProposition`` with a ``ValuePropositionAction``-
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
    func process(_ valueProposition: RawValueProposition,
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
        let newStatus = try makeStatus(from: session, and: action.status)
        session.status = newStatus
        update(session, at: index)
        return session
    }
    
    private func initialiseSession(for valueProposition: RawValueProposition,
                                   and action: ValuePropositionAction)
    throws -> ValuePropositionSession {
        if action.status == .open {
            let newSession = ValuePropositionSession(
                for: valueProposition)
            sessions.append(newSession)
            return newSession
        } else {
            throw Error.initialActionNeedsToBeOpen
        }
    }
    
    private func update(_ session: ValuePropositionSession, at index: Int) {
        switch session.status {
        case .opened, .started, .paused:
            sessions[index] = session
        case .canceled, .completed:
            sessions.remove(at: index)
        }
    }
    
    private func getFirstIndexSimilarValueProposition(as valueProposition: RawValueProposition) -> Int? {
        sessions.firstIndex { valueProposition.isEqual(to: $0.valueProposition) }
    }
    
    private func makeStatus(from session: ValuePropositionSession,
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
            session.makeRawAnalyticsEvent(action: action)))
    }
    
    private func publishEvent(for session: ValuePropositionSession,
                              with trigger: TentaclesEventTrigger) {
        _eventPublisher.send(.success(
            session.makeRawAnalyticsEvent(trigger: trigger)))
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
            update(newSession, at: index)
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
