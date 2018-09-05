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
    func logGameStartedEvent(gameType : Int) {
 // Developer mode
//        FBSDKAppEvents.logEvent("gameStarted", parameters: ["gameType" : NSNumber(value:gameType)])
//        self.logUnlockedAchievementEvent(description: "\(gameType)")
    }
    func logGameEndedEvent(holesPlayed : Int, gameT : Int) {
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["holesPlayed" : NSNumber(value:holesPlayed)])
        dict.addEntries(from: ["gameType" : NSNumber(value:gameT)])
 // Developer mode
//        FBSDKAppEvents.logEvent("gameEnded", valueToSum: Double(holesPlayed), parameters: dict as! [AnyHashable : Any])
//        self.logAchievedLevelEvent(level: "\(holesPlayed)")
    }
    
    func logAchievedLevelEvent(level : String) {
         // Developer mode
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["Level" : level])
        FBSDKAppEvents.logEvent("Levels Achieved", parameters: dict as! [AnyHashable : Any])
    }
    func logUnlockedAchievementEvent(description : String) {
         // Developer mode
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["Discription" : description])
        FBSDKAppEvents.logEvent("Achievements Unlocked", parameters: dict as! [AnyHashable : Any])
    }
}
