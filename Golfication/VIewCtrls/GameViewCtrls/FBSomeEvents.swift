//
//  FBSomeEvents.swift
//  Golfication
//
//  Created by Khelfie on 29/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FirebaseAnalytics
class FBSomeEvents: NSObject {
    static let shared = FBSomeEvents()
    override init(){}
    //Working
    func logGameStartedEvent(gameType : Int) {
        FBSDKAppEvents.logEvent("gameStarted", parameters: ["gameType" : NSNumber(value:gameType)])
        self.logUnlockedAchievementEvent(description: "\(gameType)")
    }
    func logGameEndedEvent(holesPlayed : Int, valueToSum : Double) {
        let dict = NSMutableDictionary()
        dict.addEntries(from: ["holesPlayed" : NSNumber(value:holesPlayed)])
        dict.addEntries(from: ["gameType" : NSNumber(value:valueToSum)])
        FBSDKAppEvents.logEvent("gameEnded", valueToSum: Double(holesPlayed), parameters: (dict as! [AnyHashable : Any]))
        self.logAchievedLevelEvent(level: "\(holesPlayed)")
    }
    func logAchievedLevelEvent(level : String) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAchievedLevel, parameters: [FBSDKAppEventParameterNameLevel : level])
    }
    func logUnlockedAchievementEvent(description : String) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameUnlockedAchievement, parameters: [FBSDKAppEventParameterNameDescription : description])
    }
    // after sign up
    func logCompleteRegistrationEvent (registrationMethod: String) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameCompletedRegistration, parameters: [FBSDKAppEventParameterNameRegistrationMethod : true])
    }
    
    // home screen after sign up
    func logCompleteTutorialEvent (contentData:String,contentId:String,success:Bool) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameCompletedTutorial, parameters: [FBSDKAppEventParameterNameContent : contentData,FBSDKAppEventParameterNameContentID:contentId,FBSDKAppEventParameterNameSuccess:true])
    }
    
    // on update of homecourse details
    func logFindLocationEvent () {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameFindLocation)
    }
    // on launching eddie popup
    func logInitiateCheckoutEvent () {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameInitiatedCheckout, parameters: [FBSDKAppEventParameterNameContent : "",FBSDKAppEventParameterNameContentID:"",FBSDKAppEventParameterNameContentType:"",FBSDKAppEventParameterNameNumItems:1,FBSDKAppEventParameterNamePaymentInfoAvailable:1,FBSDKAppEventParameterNameCurrency:""])
    }
    
    // on purchase click both monthly yearly
    func logAddToCartEvent (type:String,price:Int) {
        FBSDKAppEvents.logEvent(FBSDKAppEventNameAddedToCart,parameters: [FBSDKAppEventParameterNameContent : type,FBSDKAppEventParameterNameContentID:"",FBSDKAppEventParameterNameContentType:"",FBSDKAppEventParameterNameCurrency:""])
    }
    
    //MARK: Eddie Events
    
    func singleParamFBEvene(param:String,hole:Int? = nil){
//        let isDevelopment = BackgroundMapStats.isDevelopmentProvisioningProfile()
//        if !isDevelopment{
            var str = String()
            for char in param{
                if char != " "{
                    str.append(char)
                }
            }
            FBSDKAppEvents.logEvent(str)
            if hole != nil{
                Analytics.logEvent(str, parameters: ["hole":hole!])
            }else{
                Analytics.logEvent(str, parameters: [:])
            }
        }
//    }
}
