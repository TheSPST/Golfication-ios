//
//  Club.swift
//  Golfication
//
//  Created by IndiRenters on 11/17/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
class Club : NSObject{
    var backswing: Double!
    var distance: Double!
    var strokesGained: Double!
    var swingScore: Double!
    var type : Int!
    var proximity : Double!
    var holeout : Double!
    override init() {
        backswing = 0.0
        distance = 0.0
        strokesGained = 0.0
        swingScore = 0.0
        type = -1
        proximity = 0.0
        holeout = 0.0
    }
}
