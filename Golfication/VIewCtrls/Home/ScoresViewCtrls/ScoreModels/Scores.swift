//
//  Scores.swift
//  Golfication
//
//  Created by IndiRenters on 11/11/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import UIKit

class Scores: NSObject {
    var roundName : String!
    var course: String!
    var courseId: String!
    var fairwayHit: Double!
    var fairwayMiss: Double!
    var fairwayRightValue:Double!
    var fairwayLeftValue : Double!
    var gir: Double!
    var par: Int!
    var parWise : Dictionary<String, Dictionary<String,Int>>!
    var penalty:Double!
    var score: Double!
    var scoring: Dictionary<String,Int>!
    var tees : NSDictionary!
    var timestamp: Double!
    var type: String!
    var date: String!
    var putts : Array<Double>!
    var chipping : [[Chipping]] = []
    var chipUnD : ChipUnD = ChipUnD()
    var sand : [[Chipping]] = []
    var sandUnD : ChipUnD = ChipUnD()
    var approach : [[Chipping]] = []
    var girMiss : Double!
    var girWithFairway: Double!
    var girWoFairway: Double!
    var clubDict = [(String,Club)]()
}

class Hole:NSObject{
    var club: String!
    var distance: Double!
    var spread: Double!
    var hitMiss : String!
}

class ParWise: NSObject{
    var three : Double!
    var four : Double!
    var five : Double!
    override init() {
        three = 0
        four = 0
        five = 0
    }
}
class Scoring:NSObject{
    var doubleBogey: Double!
    var bogey: Double!
    var par: Double!
    var birdie: Double!
    var eagle: Double!
    override init() {
        doubleBogey = 0
        bogey = 0
        par = 0
        birdie = 0
        eagle = 0
    }
}
class Chipping:NSObject{
    var club: String!
    var distance: Double!
    var hole: Int!
    var proximityX: Double!
    var proximityY: Double!
    var und: Int!
    var green : Bool!
    override init() {
        club = ""
        distance = 0.0
        hole = 0
        proximityX = 0.0
        proximityY = 0.0
        und = -1
        green = false
    }
}
class HoleShotPar:NSObject{
    var hole: Int!
    var shot: Int!
    var par : Int!
    override init() {
        par = 0
        shot = 0
        hole = 0
    }
}

class ChipUnD:NSObject{
    var achieved: Double!
    var attempts: Double!
    override init() {
        achieved = 0.0
        attempts = 0.0
    }
}
