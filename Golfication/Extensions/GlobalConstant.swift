//
//  GlobalConstant.swift
//  Golfication
//
//  Created by Rishabh Sood on 01/11/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import Foundation

struct Constants{
    
    /*static let COGNITO_POOL_ID = "us-east-1:959a3f96-d6ba-44dd-9fa4-b414d436db97"
    
    static let EditedRound = false
    // game mode and types
    static let gameType9 = "9 holes"
    static var gameType = "18 holes"
    static let modeAdvanced = "advanced"
    static let modeRangefinder = "rangefinder"
    static let modeClassic = "classic"

    // subscriptions
    static let proMonthlyTrial = "pro_subscription_trial_monthly"
    static let proMonthly = "pro_subscription_monthly"
    static let proYearlyTrial = "pro_subscription_trial_yearly"
    static let proYearly = "pro_subscription_yearly"
    static let monthlySubscriptionID = "com.golfication.monthly"
    static let monthlyTrialSubscriptionID = "com.golfication.monthly.trial"
    static let yearlySubscriptionID = "com.golfication.yearly"
    static let yearlyTrialSubscriptionID = "com.golfication.yearly.trial"
    static let proFreeMembership = "Free_Membership"
    static let proFreeMembershipYearly = "Free_Membership_Yearly"
    static let API_KEY_SUBSCRIPTION = "MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjKfv1fQQ1WjqnDko/F0A8WFaj5epYnihac8ack8yR9Is3tgeyYe1VJ1uprq4f+kPJq52TrcP1S8Tfrea+IdONUv32Zka5caKCMDpJ6X07uNJgp1Nb/lZJfJ5m7C9ePueUwYw3RgeeCT6MuqHKt9qqAGaL6IKZSQq/dbCGQulM0kMMFTaDl18pZ2kl0DFxJ0X8GpzoaDNJd6U/qGkQYmBZGN/279TCvA0P3FX1UXsKOe6dDeDN3WgyV0wT0+GleVJSFw+FD+YdeASgF/di7QYA4aQSPAyDO2O89HEYnoKXGhXMJ6/8rBdHPhz8JS2b+qyNh/C/g9o6aJUepp3POticwIDAQAB"
    
    // player status
    static let statusDeclined = 0
    static let statusWaiting = 1
    static let statusAccepted = 2
    static let statusFinishedTemp = 3
    static let statusFinished = 4
    
    //permission Request and activity Result
    static let CAMERA_PERMISSION_REQUEST = 21
    static let GALLERY_PERMISSION_REQUEST = 22
    static let MY_LOCATION_PERMISSION_REQUEST = 23
    static let CAMERA_ACTIVITY_REQUEST = 24
    static let GALLERY_ACTIVITY_REQUEST = 25*/
    
    // MARK: NewHomeVC
//    static let DEVICEDATA = DeviceData()
    static var baselineDict: NSDictionary!
    static var strokesGainedDict = [NSMutableDictionary]()
    static var isUpdateInfo = false
    static var isProfileUpdated = false
    static var strkGainedString = ["strokesGained","strokesGained1","strokesGained2","strokesGained3","strokesGained4"]
    static var ble: BLE!
    static var clubWithMaxMin = [(name:String,max:Int,min:Int)]()
    static var isDevice = Bool()
    static var isProMode = Bool()
    static var firmwareVersion : Int!
    
    // MARK: GolfBagTabsVC
    static var syncdArray = NSMutableArray()
    static var tagClubNum = [(tag:Int, club: Int, clubName: String)]()
    // MARK: BLE
    static var ResponseData : Data!
    static var deviceGolficationX: CBPeripheral!
    static var charctersticsGlobalForWrite : CBCharacteristic!
    static var charctersticsGlobalForRead : CBCharacteristic!
    static var allClubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"]
    // MARK: BLESCANNING
    static var bleObserver = 0
    // MARK: FeedPostVC
    static var fromStatsPost = false
    //MARK: SwingsSessions
    static var benchmark_Key = String()
    // MARK: FilterVC
    static var finalFilterDic = NSMutableDictionary()
    static var section5 = [String]()

    // MARK: ProfileProMemberPopUPVC
    static var fromIndiegogo = Bool()

    //Settings
    static var distanceFilter = 0
    static var skrokesGainedFilter = 0
    static var onCourseNotification = 0

    // MARK: New Game
    static var selectedGolfID: String = ""
    static var selectedGolfName: String = ""
    static var selectedLat: String = ""
    static var selectedLong: String = ""
    static var matchDataDic = NSMutableDictionary()
    static var gameType: String = "18 holes"
    static var startingHole: String = "1"
    static var matchId = String()
    static var mode = Int()
    static var selectedTee = ""
    static var selectedTeeColor = ""
    static var selectedSlope = Int()
    static var selectedRating = String()
    static var teeArr = [(name:String,type:String,rating:String,slope:String)]()
    static var handicap = Double()
    static var isEdited = Bool()

    // MARK: CustomPopUpViewController
    static var isAdvanced = true

    // MARK: SearchPlayerVC
    static var selectedIndex = NSMutableArray()
    static var addPlayersArray = NSMutableArray()
    
    // MARK: IAPHandler
    static let AUTO_RENEW_MONTHLY_PRODUCT_ID = "pro_subscription_monthly"
    static let AUTO_RENEW_YEARLY_PRODUCT_ID = "pro_subscription_yearly"
    static let AUTO_RENEW_TRIAL_MONTHLY_PRODUCT_ID = "pro_subscription_trial_monthly"
    static let AUTO_RENEW_TRIAL_YEARLY_PRODUCT_ID = "pro_subscription_trial_yearly"
    static let PROMO_CODE_YEARLY_PRODUCT_ID = "Free_Membership_Yearly"
    static let FREE_MONTHLY_PRODUCT_ID = "Free_Membership"
}
