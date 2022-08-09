//
//  File.swift
//  
//
//  Created by Patrick Fischer on 19.07.22.
//

import Foundation
import Tentacles

typealias WatchingVideoDomainActivity = DomainActivity<WatchingVideoAttributes>
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

typealias CommentingDomainActivity = DomainActivity<KeyValueAttribute<Bool>>

extension CommentingDomainActivity {
    static let stub: Self = .init(name: "commenting", attributes: .init(key: "replyToOtherComment", value: false))
}
                                                            
