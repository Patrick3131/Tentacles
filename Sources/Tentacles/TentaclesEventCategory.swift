//
//  TentaclesEventCategory.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public enum TentaclesEventCategory: String, AnalyticsEventCategory {
    case appOnboarding
    case chat
    case content
    case deviceEvents
    case domainActivity
    case error
    case fileOperations
    case gaming
    case inAppPurchase
    case interaction
    case lifecycle
    case location
    case mediaPlayback
    case navigation
    case network
    case performance
    case personalization
    case promotions
    case pushNotification
    case screen
    case search
    case settings
    case social
    case userAction
    case userAuthentication

    public var name: String {
        self.rawValue
    }
}
