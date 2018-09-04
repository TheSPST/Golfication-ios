//
//  Bound.swift
//  Golfication
//
//  Created by IndiRenters on 11/23/17.
//  Copyright © 2017 Khelfie. All rights reserved.
//

import Foundation
class Bounds : NSObject {
    var maxLat : Double?
    var maxLng : Double?
    var minLat : Double?
    var minLng : Double?
    var par : Int?
    
    override init() {
        maxLat = 0.0
        maxLng = 0.0
        minLat = 0.0
        minLng = 0.0
        par = -1
    }
}
class Properties:NSObject{
    var hole: Int?
    var label: String?
    var type: String?
    override init() {
        hole = -1
        label = ""
        type = ""
    }
}
class LatLng:NSObject{
    var latitude:Double?
    var longitude:Double?
    override init(){
        latitude = -1
        longitude = -1
    }
}
