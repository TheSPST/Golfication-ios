//
//  GlobalConstant.swift
//  Golfication
//
//  Created by Rishabh Sood on 01/11/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import Foundation

struct Constants{
    
    // MARK: NewHomeVC
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
    static var oldFirmwareVersion : Int!
    static var canSkip : Bool!
    static var gender = ""
    static var handed = ""
    static var handicap = ""
    static var trial = false
    static let catagoryWise = ["Off the Tee","Approach","Around The Green","Putting"]
    static let YARD:Double = 1.09361
    static var tagClubNumber = [(tag:Int ,club:Int,clubName:String)]()
    // MARK: GolfBagTabsVC
    static var syncdArray = NSMutableArray()
    static var tagClubNum = [(tag:Int, club: Int, clubName: String)]()
    static var back9 = false
    static var macAddress : String!
    // MARK: BLE
    static var ResponseData : Data!
    static var deviceGolficationX: CBPeripheral!
    static var charctersticsGlobalForWrite : CBCharacteristic!
    static var charctersticsGlobalForRead : CBCharacteristic!
    static var allClubs = ["Dr","3w","1i","1h","2h","3h","2i","4w","4h","3i","5w","5h","4i","7w","6h","5i","7h","6i","7i","8i","9i","Pw","Gw","Sw","Lw","Pu"]
    static var OADFeedback = false
    // MARK: BLESCANNING
    static var bleObserver = 0
    static var fileName = String()
    static var swingSessionKey = String()
    // MARK: FeedPostVC
    static var fromStatsPost = false
    
    //MARK: SwingsSessions
    static var benchmark_Key = String()
    
    // MARK: FilterVC
    static var finalFilterDic = NSMutableDictionary()
    static var section5 = [String]()

    // MARK: ProfileProMemberPopUPVC
    static var fromIndiegogo = Bool()

    // MARK: Settings
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
