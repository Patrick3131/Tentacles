//
//  PFActivityManagerTracking.swift
//  
//
//  Created by Patrick Fischer on 12.07.22.
//

import Foundation
import Combine

/// Manages sessions of ``DomainActivity``s.
class DomainActivitySessionManager {
    enum Error: Swift.Error {
        case initialActionNeedsToBeOpen
        case prohibitedStateUpdate(session: DomainActivitySession,
                                   action: DomainActivityAction.Status)
        case selfWasNil
    }
    private let _eventPublisher: PassthroughSubject<Result<RawAnalyticsEvent, Swift.Error>, Never> = .init()
    lazy var eventPublisher = _eventPublisher.eraseToAnyPublisher()
    
    private var sessions = [DomainActivitySession]()
    private let lock = NSLock()
    
    /// Processes a ``DomainActivity`` with a ``DomainActivityAction``-
    ///
    /// When a ``DomainActivity`` is tracked with an ``DomainActivityAction``, the status of the session is
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
    func process(_ domainActivity: RawDomainActivity,
                 with action: DomainActivityAction) {
        lock.lock()
        do {
            let session: DomainActivitySession
            if let index = getFirstIndexSimilarDomainActivity(as: domainActivity) {
                session = try processActiveSession(for: action,
                                                   at: index)
            } else {
                session = try initialiseSession(for: domainActivity,
                                                and: action)
            }
            publishEvent(for: session, with: action)
        } catch {
            publish(error)
        }
        lock.unlock()
    }
    
    private func processActiveSession(for action: DomainActivityAction,
                                      at index: Int) throws -> DomainActivitySession {
        var session = sessions[index]
        let newStatus = try makeStatus(from: session, and: action.status)
        session.status = newStatus
        update(session, at: index)
        return session
    }
    
    private func initialiseSession(for domainActivity: RawDomainActivity,
                                   and action: DomainActivityAction)
    throws -> DomainActivitySession {
        guard action.status == .open else {
            throw Error.initialActionNeedsToBeOpen
        }
        let newSession = DomainActivitySession(
            for: domainActivity)
        sessions.append(newSession)
        return newSession
    }
    
    private func update(_ session: DomainActivitySession, at index: Int) {
        switch session.status {
        case .opened, .started, .paused:
            sessions[index] = session
        case .canceled, .completed:
            sessions.remove(at: index)
        }
    }
    
    private func getFirstIndexSimilarDomainActivity(as domainActivity: RawDomainActivity) -> Int? {
        sessions.firstIndex { $0.domainActivity == domainActivity }
    }
    
    private func makeStatus(from session: DomainActivitySession,
                            and actionStatus: DomainActivityAction.Status) throws
    -> DomainActivitySession.Status {
        switch (session.status, actionStatus) {
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
    
    private func publishEvent(for session: DomainActivitySession,
                              with action: DomainActivityAction) {
        _eventPublisher.send(.success(
            session.makeRawAnalyticsEvent(action: action)))
    }
    
    private func publishEvent(for session: DomainActivitySession,
                              with trigger: TentaclesEventTrigger) {
        _eventPublisher.send(.success(
            session.makeRawAnalyticsEvent(trigger: trigger)))
    }
    
    //MARK: Background & Foreground Applifecycle
    
    /// Sessions before app went in to background, will be used to reset sessions in case
    /// app enters foreground again.
    private var cachedSessions = [DomainActivitySession]()
    
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
