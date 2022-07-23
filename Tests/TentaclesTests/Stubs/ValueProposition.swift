//
//  File.swift
//  
//
//  Created by Patrick Fischer on 19.07.22.
//

import Foundation
import Tentacles

struct WatchingVideoValueProposition: ValueProposition {
    let name: String = "watchingVideo"
    let attributes: AnalyticsEventAttributes
    init(attributes: Attributes) {
        self.attributes = attributes
    }
    
    static let stub: Self = .init(attributes:
            .init(videoName: "Learning Swift",
                  language: "English", duration: 450))
}

extension WatchingVideoValueProposition {
    struct Attributes: AnalyticsEventAttributes {
        let videoName: String
        let language: String
        /// in seconds
        let duration: Double
    }
}

struct WatchingVideoCompletionAttributes: AnalyticsEventAttributes {
    let secondsSkipped: Double
    let userCommented: Bool
}

struct CommentingValueProposition: ValueProposition {
    let name: String = "commenting"
    let attributes: AnalyticsEventAttributes
    
    static let stub: Self = .init(attributes: Attributes(replyToOtherComment: false))
}

extension CommentingValueProposition {
    struct Attributes: AnalyticsEventAttributes {
        let replyToOtherComment: Bool
    }
}




struct ValuePropositionTrackingStub: ValuePropositionTracking {
    func track(for valueProposition: ValueProposition,
               with action: ValuePropositionAction) {
        
    }
}
