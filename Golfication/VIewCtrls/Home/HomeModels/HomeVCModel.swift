//
//  HomeVCModel.swift
//  Golfication
//
//  Created by IndiRenters on 11/6/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class HomeVCModel : NSObject{
    //----------- HomeTopFeed Data------------
    var clubName :String?
    var distanceWithUnit = String()
    var strokesGainedValue :Double?
    var totalScore :Double?
    var swingScore :Double?
    var strokesGained :Double?
    var strokesCount : Double?
    var maxScore :Double?
    var round_score: [Double] = []
    var round_time: [String] = []
    var roundType:[String] = []
    var card3PieDic :NSDictionary?
    var card4AchievDic :NSDictionary?
}

class HomeRounds : NSObject{
    var score:Double!
    var timestamp:Double!
    var handicap : NSDictionary!
}
