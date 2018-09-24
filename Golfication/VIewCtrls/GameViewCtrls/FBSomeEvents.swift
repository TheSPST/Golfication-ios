//
//  FBSomeEvents.swift
//  Golfication
//
//  Created by Khelfie on 29/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FBSomeEvents: NSObject {
    static let shared = FBSomeEvents()
    override init(){}
    //Working
    func logGameStartedEvent(gameType : Int) {
//        FBSDKAppEvents.logEvent("gameStarted", parameters: ["gameType" : NSNumber(value:gameType)])
//        self.logUnlockedAchievementEvent(description: "\(gameType)")
    }
    func logGameEndedEvent(holesPlayed : Int, valueToSum : Double) {
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["holesPlayed" : NSNumber(value:holesPlayed)])
        dict.addEntries(from: ["gameType" : NSNumber(value:valueToSum)])
//        FBSDKAppEvents.logEvent("gameEnded", valueToSum: Double(holesPlayed), parameters: (dict as! [AnyHashable : Any]))
//        self.logAchievedLevelEvent(level: "\(holesPlayed)")
    }
    func logAchievedLevelEvent(level : String) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAchievedLevel, parameters: [FBSDKAppEventParameterNameLevel : level])
        
    }
    func logUnlockedAchievementEvent(description : String) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameUnlockedAchievement, parameters: [FBSDKAppEventParameterNameDescription : description])
    }
}
