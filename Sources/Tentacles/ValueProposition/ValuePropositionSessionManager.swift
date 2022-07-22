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
struct ValuePropositionSessionManager {
    enum Error: Swift.Error {
        
    }
    private var managedActivities = [ValuePropositionSession]()

    private var _publisher = PassthroughSubject<AnalyticsEvent, Never>()
    public lazy var trackingEvent: AnyPublisher<
        AnalyticsEvent, Never> = _publisher.eraseToAnyPublisher()

    func updateSession(for valueProposition: ValueProposition,
                        with action: ValuePropositionAction) {
        
    }
    
    private func getFirstActivity(for valueProposition: ValueProposition) -> ValuePropositionSession? {
        for activity in managedActivities {
            if (activity.valueProposition.name == valueProposition.name)
                &&
                (activity.valueProposition.attributes.serialiseToValue()
                 == valueProposition.attributes.serialiseToValue()) {
                return activity
            }
        }
        return nil
    }
}
