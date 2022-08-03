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
    let attributes: Attributes
    init(attributes: Attributes) {
        self.attributes = attributes
    }
    
    static let stub: Self = .init(attributes:
            .init(videoName: "Learning Swift",
                  language: "English",
                  duration: 450))
}

extension WatchingVideoValueProposition {
    struct Attributes: TentaclesAttributes {
        let videoName: String
        let language: String
        /// in seconds
        let duration: Double
    }
}

struct WatchingVideoCompletionAttributes: TentaclesAttributes {
    let secondsSkipped: Double
    let userCommented: Bool
}

struct CommentingValueProposition: ValueProposition {
    let name: String = "commenting"
    let attributes: KeyValueAttribute<Bool>
    
    static let stub: Self = .init(attributes: .init(key: "replyToOtherComment", value: false))
}
