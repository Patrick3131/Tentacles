//
//  TentaclesEventTrigger.swift
//  
//
//  Created by Patrick Fischer on 30.07.22.
//

import Foundation

public enum TentaclesEventTrigger: String, AnalyticsEventTrigger {
    case appLanguageChanged
    case appSettingsChanged
    case applicationWillTerminate
    case authenticationFailed
    case authenticationSucceeded
    case buttonLongPressed
    case cellSelected
    case clicked
    case deepLinkOpened
    case didEnterForeground
    case didReceiveMemoryWarning
    case inAppPurchaseCompleted
    case inAppPurchaseFailed
    case inAppPurchaseInitiated
    case inAppPurchaseRestored
    case locationAuthorizationChanged
    case locationUpdated
    case logout
    case networkRequestCompleted
    case networkRequestFailed
    case networkRequestStarted
    case pushNotificationReceived
    case pushNotificationTapped
    case refreshControlActivated
    case searchBarTextChanged
    case screenDidAppear
    case segmentedControlValueChanged
    case sliderValueChanged
    case switchValueChanged
    case textFieldDidChange
    case userDeletedAccount
    case userInitiated
    case userSignedUp
    case userUpdatedProfile
    case viewTapped
    case viewDidLoad
    case viewWillAppear
    case viewWillDisappear
    case willResignActive

    public var name: String {
        self.rawValue
    }
}
