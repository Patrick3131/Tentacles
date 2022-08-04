//
//  File.swift
//  
//
//  Created by Patrick Fischer on 19.07.22.
//

import Foundation
import Tentacles


//static let stub: Self = .init(attributes:
//        .init(videoName: "Learning Swift",
//              language: "English",
//              duration: 450))
typealias WatchingVideoValueProposition = ValueProposition<WatchingVideoAttributes>
struct WatchingVideoAttributes: TentaclesAttributes {
    let videoName: String
    let language: String
    /// in seconds
    let duration: Double
}

struct WatchingVideoCompletionAttributes: TentaclesAttributes {
    let secondsSkipped: Double
    let userCommented: Bool
}

typealias CommentingValueProposition = ValueProposition<KeyValueAttribute<Bool>>

extension CommentingValueProposition {
    static let stub: Self = .init(name: "commenting", attributes: .init(key: "replyToOtherComment", value: false))
}
                                                            
