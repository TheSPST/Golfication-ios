//
//  BackgroundMapStats.swift
//  Golfication
//
//  Created by Khelfie on 12/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps

class BackgroundMapStats: NSObject {
    var scoring = [(hole:Int,par:Int,players:[NSMutableDictionary])]()
    var selectedCourseId = String()
    var selectedCourseName = String()
    var selectedGameType = Int()
    var holeOutCount = Int()
    var polygonArray = [[CLLocationCoordinate2D]]()
    var numberOfHoles = [(hole: Int,tee:[[CLLocationCoordinate2D]] ,fairway:[[CLLocationCoordinate2D]], green:[CLLocationCoordinate2D],fb:[[CLLocationCoordinate2D]],gb:[[CLLocationCoordinate2D]],wh:[[CLLocationCoordinate2D]])]()
    var propertyArray = [Properties]()
    var centerPointOfTeeNGreen = [(tee:CLLocationCoordinate2D,green:CLLocationCoordinate2D)]()
    var positionsOfDotLine = [CLLocationCoordinate2D]()
    var positionsOfCurveLines = [CLLocationCoordinate2D]()
    var gir = Bool()
    var penaltyShots = [Bool]()
    var currentMatchId = String()
    var holeOutFlag = false
    static var blockRecursionIssue = 0
    func getScoreFromMatchDataFirebase(keyId:String){
        self.currentMatchId = keyId
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(keyId)/") { (snapshot) in
            self.scoring.removeAll()
            if  let matchDict = (snapshot.value as? NSDictionary){
                matchDataDic = matchDict as! NSMutableDictionary
                var scoreArray = NSArray()
                var keyData = String()
                var playersKey = [String]()
                for (key,value) in matchDict{
                    keyData = key as! String
                    if(keyData == "player"){
                        for (k,_) in value as! NSMutableDictionary{
                            playersKey.append(k as! String)
                        }
                    }
                    if(keyData == "courseId"){
                        self.selectedCourseId = value as! String
                    }
                    if(keyData == "courseName"){
                        self.selectedCourseName = value as! String
                    }
                    if (keyData == "scoring"){
                        scoreArray = (value as! NSArray)
                    }
                    
                    if(keyData == "matchType"){
                        if(value as! String == "18 holes"){
                            self.selectedGameType = 18
                        }
                        else{
                            self.selectedGameType = 9
                        }
                    }
                }
                self.holeOutCount = 0
                for i in 0..<scoreArray.count {
                    var playersArray = [NSMutableDictionary]()
                    var par:Int!
                    let score = scoreArray[i] as! NSDictionary
                    for(key,value) in score{
                        if(key as! String == "par"){
                            par = value as! Int
                        }
                        for playerId in playersKey{
                            if(key as! String)==playerId{
                                let dict = NSMutableDictionary()
                                dict.setObject(value, forKey: key as! String as NSCopying)
                                if((key as! String) == Auth.auth().currentUser!.uid){
                                    if(((value as! NSMutableDictionary).value(forKey: "holeOut")) as! Bool){
                                        self.holeOutCount += 1
                                    }
                                }
                                playersArray.append(dict)
                            }
                        }
                    }
                    self.scoring.append((hole: i, par:par,players:playersArray))
                    self.numberOfHoles.append((i+1,[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]](),[CLLocationCoordinate2D](),[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]](),[[CLLocationCoordinate2D]]()))

                }
            }
            DispatchQueue.main.async(execute: {
                self.getGolfCourseDataFromFirebase(courseId: self.selectedCourseId)
            })
        }
    }
    
    func getGolfCourseDataFromFirebase(courseId:String){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseGolf(addedPath: "course_\(courseId)") { (snapshot) in
            let group = DispatchGroup()
            let completeDataDict = (snapshot.value as? NSDictionary)!
            for(key,value) in completeDataDict{
                group.enter()
                if ((key as! String) == "coordinates"){
                    let coordinatesArray = (value as? NSArray)!
                    var types = [String]()
                    for data in coordinatesArray{
                        let coordinateDict = (data as? NSDictionary)!
                        for(key,value) in coordinateDict{
                            if((key as! String) == "type"){
                                types.append(value as! String)
                            }
                            else if((key as! String) == "geometry"){
                                let geometryDict = value as! NSDictionary
                                for(key,value) in geometryDict{
                                    if((key as! String) == "coordinates"){
                                        let coordArray = value as! NSArray
                                        var polygon = [CLLocationCoordinate2D]()
                                        for data in coordArray{
                                            let latlongArray = data as! NSArray
                                            for position in latlongArray{
                                                let positionArray = position as! NSArray
                                                polygon.append(CLLocationCoordinate2D(latitude: positionArray[1] as! CLLocationDegrees,longitude: positionArray[0] as! CLLocationDegrees))
                                            }
                                        }
                                        self.polygonArray.append(polygon)
                                    }
                                }
                            }
                            else if((key as! String) == "properties"){
                                let property = Properties()
                                if let hole = (value as AnyObject).object(forKey:"hole") as? String{
                                    property.hole = Int(hole)
                                }
                                else if let hole = (value as AnyObject).object(forKey:"hole") as? Int{
                                    property.hole = hole
                                }
                                property.label = (value as AnyObject).object(forKey:"label") as? String
                                property.type = (value as AnyObject).object(forKey:"type") as? String
                                self.propertyArray.append(property)
                            }
                        }
                    }
                }
                group.leave()
            }
            
            group.notify(queue: .main){
                
                for j in 0..<self.numberOfHoles.count{
                    for i in 0..<self.polygonArray.count{
                        if(self.propertyArray[i].hole == self.numberOfHoles[j].hole){
                            if(self.propertyArray[i].type == "T"){
                                self.numberOfHoles[j].tee.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "G"){
                                self.numberOfHoles[j].green = self.polygonArray[i]
                            }
                            if(self.propertyArray[i].type == "F"){
                                self.numberOfHoles[j].fairway.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "FB"){
                                self.numberOfHoles[j].fb.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "GB"){
                                self.numberOfHoles[j].gb.append(self.polygonArray[i])
                            }
                            if(self.propertyArray[i].type == "WH"){
                                self.numberOfHoles[j].wh.append(self.polygonArray[i])
                            }
                        }
                    }
                }
                for data in self.numberOfHoles{
                    var centerOfTee = [CLLocationCoordinate2D]()
                    var indexOfMaxDistanceTee = 0
                    var distanceBwGreenNHole = 0.0
                    for tee in data.tee{
                        centerOfTee.append(BackgroundMapStats.middlePointOfListMarkers(listCoords: tee))
                    }
                    for t in 0..<centerOfTee.count{
                        if(distanceBwGreenNHole < GMSGeometryDistance(centerOfTee[t], BackgroundMapStats.middlePointOfListMarkers(listCoords: data.green))){
                            distanceBwGreenNHole = GMSGeometryDistance(centerOfTee[t], BackgroundMapStats.middlePointOfListMarkers(listCoords: data.green))
                            indexOfMaxDistanceTee = t
                        }
                    }
                    let centerTee = centerOfTee[indexOfMaxDistanceTee]
                    let centerOfGreen = BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green)
                    self.centerPointOfTeeNGreen.append((tee: centerTee,green: centerOfGreen))
                }
                for shots in self.scoring{
                    for i in 0..<shots.players.count{
                        if let playerShots = shots.players[i].value(forKey: Auth.auth().currentUser!.uid) as? NSMutableDictionary{
                            if let swing = playerShots.value(forKeyPath: "swing") as? Bool{
                                if swing {
                                    self.holeOutFlag = playerShots.value(forKeyPath: "holeOut") as! Bool
                                    if let shotsArr = playerShots.value(forKeyPath: "shots") as? [NSMutableDictionary]{
                                        self.calculateShots(hole:shots.hole,shotsArray:shotsArr)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    func calculateShots(hole:Int,shotsArray:[NSMutableDictionary]){
        for i in 0..<shotsArray.count {
            let shotLatLng = shotsArray[i]
            self.penaltyShots.append(shotLatLng.value(forKey: "penalty") as! Bool)
            positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
            if(holeOutFlag) && i == shotsArray.count-1{
                positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat2") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng2") as! CLLocationDegrees))
            }else if i == shotsArray.count-1 {
                positionsOfDotLine.append(CLLocationCoordinate2D.init(latitude: shotLatLng.value(forKey: "lat1") as! CLLocationDegrees, longitude: shotLatLng.value(forKey: "lng1") as! CLLocationDegrees))
                self.positionsOfDotLine.append(centerPointOfTeeNGreen[hole].green)
                
                let newDict = NSMutableDictionary()
                newDict.setObject(shotLatLng.value(forKey: "club") as! String, forKey: "club" as NSCopying)
                newDict.setObject(self.positionsOfDotLine.first!.latitude, forKey: "lat1" as NSCopying)
                newDict.setObject(self.positionsOfDotLine.first!.longitude, forKey: "lng1" as NSCopying)
                newDict.setObject(shotLatLng.value(forKey: "shotNum") as! Int, forKey: "shot_no" as NSCopying)
                ref.child("matchData/\(self.currentMatchId)/scoring/\(hole)/\(Auth.auth().currentUser!.uid)/shotTracking").updateChildValues(newDict as! [AnyHashable : Any])
                ref.child("matchData/\(self.currentMatchId)/scoring/\(hole)/\(Auth.auth().currentUser!.uid)/shots/\(i)/").setValue(nil)
            }
        }
        for i in 0..<positionsOfCurveLines.count-1{
            self.uploadStatsWithDragging(shot: i+1, index: hole, shotsValue: shotsArray)
        }
    }
    
    func uploadStatsWithDragging(shot:Int,index:Int,shotsValue:[NSMutableDictionary]){
        let girDict = NSMutableDictionary()
        let faiDict = NSMutableDictionary()
        
        if(shot==1) && (!positionsOfCurveLines.isEmpty){
            gir = false
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], index: index) == "G" ? true:false
            girDict.setObject(gir, forKey: "gir" as NSCopying)
            faiDict.setObject(fairwayDetailsForFirstShot(shot:shot, index: index), forKey: "fairway" as NSCopying)
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(Auth.auth().currentUser!.uid)/").updateChildValues(faiDict as! [AnyHashable : Any])
            let drivDistDict = NSMutableDictionary()
            if(self.scoring[index].par>3){
                let drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*YARD
                drivDistDict.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
            }
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(Auth.auth().currentUser!.uid)/").updateChildValues(drivDistDict as! [AnyHashable : Any])
            
        }
        else if(shot == 2)&&(!gir)&&(self.scoring[index].par>3){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], index: index) == "G" ? true:false
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        else if(shot == 3)&&(!gir)&&(self.scoring[index].par>4){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], index: index) == "G" ? true:false
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        if(holeOutFlag) && shot == shotsValue.count-1{
            uploadChipUpNDown(playerId: Auth.auth().currentUser!.uid, index:index)
            uploadSandUpNDown(playerId: Auth.auth().currentUser!.uid, index: index)
            uploadPutting(playerId: Auth.auth().currentUser!.uid, index: index)
        }
        uploadApproachAndApproachShots(playerId: Auth.auth().currentUser!.uid, index: index)
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(Auth.auth().currentUser!.uid)/").updateChildValues(girDict as! [AnyHashable : Any])
        let clubValue = shotsValue[shot-1].value(forKey: "club") as! String
        let isPenaltyShot = shotsValue[shot-1].value(forKey: "penalty") as! Bool
        let data = reCalculateStats(shot: shot, club: clubValue, isPenalty: isPenaltyShot, end: callFindPositionInsideFeature(position:positionsOfCurveLines[shot], index: index), start: callFindPositionInsideFeature(position:positionsOfCurveLines[shot-1], index: index))
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(Auth.auth().currentUser!.uid)/shots/\(shot-1)").updateChildValues(data as! [AnyHashable : Any])
        if(shot == shotsValue.count-1){
            ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(Auth.auth().currentUser!.uid)/swing").setValue(false)
        }
    }
    
    func uploadChipUpNDown(playerId : String,index:Int){
        var appDistance = Double()
        var chipUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], numberOfHoles[index].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: numberOfHoles[index].green)])*YARD
            if(appDistance<50){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i], index: index) != "GB" ){
                    chipUpDown = true
                }
                else{
                    chipUpDown = false
                }
                break
            }
            else{
                chipUpDown = nil
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/chipUpDown").setValue(chipUpDown)
    }
    func uploadSandUpNDown(playerId : String,index:Int){
        var appDistance = Double()
        var sandUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], numberOfHoles[index].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: numberOfHoles[index].green)])*YARD
            if(appDistance<50){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i], index: index) == "GB" ){
                    sandUpDown = true
                }
                else{
                    sandUpDown = false
                }
                break
            }
            else{
                sandUpDown = nil
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(self.index)/\(playerId)/sandUpDown").setValue(sandUpDown)
    }
    
    func uploadPutting(playerId:String,index:Int){
        var putting = Int()
        for i in 0..<self.scoring[index].players.count{
            if(self.scoring[index].players[i].value(forKey: playerId) != nil){
                if let scoringDict = (self.scoring[index].players[i].value(forKey: playerId) as? NSMutableDictionary){
                    if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                        for data in scoreShots{
                            let dataDict = data as! NSMutableDictionary
                            if((dataDict.value(forKey: "club") as! String).trim() == "Pu"){
                                putting += 1
                            }
                        }
                        break
                    }
                }
            }
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/putting").setValue(putting)
    }
    func uploadApproachAndApproachShots(playerId:String,index:Int){
        var approachDistance = 0.0
        let appDistDict = NSMutableDictionary()
        for i in 0..<positionsOfCurveLines.count{
            approachDistance = GMSGeometryDistance(positionsOfCurveLines[i],self.centerPointOfTeeNGreen[index].green)*YARD
            if(approachDistance<200 && approachDistance != 0){
                appDistDict.setObject(approachDistance.rounded(toPlaces: 2), forKey: "approachDistance" as NSCopying)
                break
            }
            else{
                appDistDict.setObject("N/A", forKey: "approachDistance" as NSCopying)
            }
            
        }
        ref.child("matchData/\(self.currentMatchId)/scoring/\(index)/\(playerId)/").updateChildValues(appDistDict as! [AnyHashable : Any])
    }
    func fairwayDetailsForFirstShot(shot:Int,index:Int)->String{
        var fairwayHitOrMiss = ""
        if(callFindPositionInsideFeature(position:positionsOfCurveLines[shot], index: index) != "F"){
            fairwayHitOrMiss = isFairwayHitOrMiss(position: positionsOfCurveLines[shot])
        }
        else{
            fairwayHitOrMiss = "H"
        }
        return fairwayHitOrMiss
    }
    static func nearByPoint(newPoint:CLLocationCoordinate2D, array:[CLLocationCoordinate2D])->Int{
        var distance = [Double]()
        for coord in array{
            distance.append(GMSGeometryDistance(newPoint, coord))
        }
        return (distance.index(of: distance.min()!)!)
    }
    func reCalculateStats(shot:Int,club:String,isPenalty:Bool,end:String,start:String)->NSMutableDictionary{
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        shotDictionary.setObject(club, forKey: "club" as NSCopying)
        var start = start
        var end = end
        shotDictionary.setObject(isPenalty, forKey: "penalty" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].latitude, forKey: "lat2" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].longitude, forKey: "lng2" as NSCopying)
        shotDictionary.setObject(start, forKey: "start" as NSCopying)
        shotDictionary.setObject(end, forKey: "end" as NSCopying)
        
        let distanceBwShots = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])
        let distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines.last!)
        var distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfCurveLines.last!)
        if(distanceBwHole1 == 0) && !positionsOfDotLine.isEmpty{
            distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
        }
        shotDictionary.setObject((distanceBwShots*YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*YARD).rounded()))"
        }
        if(Int((distanceBwHole0*YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*YARD).rounded()) < 100) && shot == 0{
            start = "\(start)100"
        }
        debugPrint(start)
        debugPrint(end)
        var numberOfPenalty = 0
        if(shot < penaltyShots.count){
            for i in shot..<penaltyShots.count{
                if (self.penaltyShots[i]){
                    numberOfPenalty += 1
                }else{
                    break
                }
            }
        }
        
        for i in 0..<strkGainedString.count{
            var strkG = calculateStrokesGained(start:start,end:end,filterIndex:i)
            strkG = strkG - Double(numberOfPenalty)
            shotDictionary.setObject(strkG, forKey: strkGainedString[i] as NSCopying)
        }
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot]), forKey: "heading" as NSCopying)
        return shotDictionary
    }
    func coordLeftOrRight(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D)->String{
        let leftOrRight : String!
        var headingAngleOfStartingToGreen = 0.0
        if(holeOutFlag){
            headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfCurveLines.last!)
        }
        else{
            if(positionsOfDotLine.count != 0){
                headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfDotLine.last!)
            }
            else{
                headingAngleOfStartingToGreen = GMSGeometryHeading(start, positionsOfCurveLines[1])
            }
        }
        let headingAngleOfStartToEnd = GMSGeometryHeading(start, end)
        
        if(headingAngleOfStartToEnd < headingAngleOfStartingToGreen){
            leftOrRight = "L"
        }
        else{
            leftOrRight = "R"
        }
        return leftOrRight
    }
    static func middlePointOfListMarkers(listCoords: [CLLocationCoordinate2D]) -> CLLocationCoordinate2D{
        var x = 0.0 as CGFloat
        var y = 0.0 as CGFloat
        var z = 0.0 as CGFloat
        
        for coordinate in listCoords{
            let lat:CGFloat = ((CGFloat(coordinate.latitude)) / 180.0 * CGFloat(Double.pi))
            let lon:CGFloat = ((CGFloat(coordinate.longitude)) / 180.0 * CGFloat(Double.pi))
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon);
            z = z + sin(lat);
        }
        x = x/CGFloat(listCoords.count)
        y = y/CGFloat(listCoords.count)
        z = z/CGFloat(listCoords.count)
        
        let resultLon: CGFloat = atan2(y, x)
        let resultHyp: CGFloat = sqrt(x*x+y*y)
        let resultLat:CGFloat = atan2(z, resultHyp)
        let newLat = CLLocationDegrees(resultLat * CGFloat(180.0 / .pi))
        let newLon = CLLocationDegrees(resultLon * CGFloat(180.0 / .pi))
        let result:CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: newLat, longitude: newLon)
        return result
    }
    static func setStartingEndingChar(str:String)->String{
        let typeArray = ["F","G","R","S","T"]
        var returnedStr = String()
        if(!typeArray.contains(str)){
            if(str == "GB" || str == "FB"){
                returnedStr = "S"
            }
            else{
                returnedStr = "R"
            }
        }
        else{
            returnedStr = str
        }
        return returnedStr
    }
    func calculateStrokesGained(start:String,end:String,filterIndex:Int)->Double{
        var strkGnd = Double()
        var startGained = Double()
        var endGained = Double()
        
        if(strokesGainedDict[filterIndex].value(forKey: start) != nil){
            startGained = strokesGainedDict[filterIndex].value(forKey: start) as! Double
        }
        if(strokesGainedDict[filterIndex].value(forKey: end) != nil){
            endGained = strokesGainedDict[filterIndex].value(forKey: end) as! Double
        }
        
        strkGnd = startGained - endGained - 1
        return strkGnd
    }
    
    func isFairwayHitOrMiss(position:CLLocationCoordinate2D)->String{
        var fairwayDetails = ""
        var headingAngleOfTeeToGreen = 0.0
        if(holeOutFlag){
            headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfCurveLines.last!)
        }else{
            headingAngleOfTeeToGreen = GMSGeometryHeading(positionsOfCurveLines.first!, positionsOfDotLine.last!)
        }
        
        var headingAngleOfTeeToFairway = 0.0
        headingAngleOfTeeToFairway = GMSGeometryHeading(positionsOfCurveLines.first!, position)
        
        if(headingAngleOfTeeToFairway < headingAngleOfTeeToGreen){
            fairwayDetails = "L"
        }
        else{
            fairwayDetails = "R"
        }
        return fairwayDetails
    }
    
    func callFindPositionInsideFeature(position:CLLocationCoordinate2D,index:Int)->String{
        var featureName = "R"
        for data in self.numberOfHoles[index].fairway{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "F"
                break
            }
        }
        for data in self.numberOfHoles[index].gb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "GB"
                break
            }
        }
        for data in self.numberOfHoles[index].fb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "FB"
                break
            }
        }
        for data in self.numberOfHoles[index].wh{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "WH"
                break
            }
        }
        for data in self.numberOfHoles[index].tee{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "T"
                break
            }
        }
        if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature:self.numberOfHoles[index].green)){
            featureName = "G"
        }
        return featureName
    }
    
    static func findPositionOfPointInside(position:CLLocationCoordinate2D,whichFeature:[CLLocationCoordinate2D])->Bool{
        let path = GMSMutablePath()
        for j in 0..<whichFeature.count{
            path.add(whichFeature[j])
        }
        if(GMSGeometryContainsLocation(position, path, true)){
            return true
        }
        return false
    }
    static func getDataFromJson(lattitude:Double,longitude:Double, onCompletion: @escaping ([String:AnyObject]?, String?) -> Void) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?lat=\(lattitude)&lon=\(longitude)&APPID=a261cc920ea8ff18f5c941b4675f1b8a")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        let task = URLSession.shared.dataTask(with: request) { Data, response, error in
            guard let data = Data, error == nil else {  // check for fundamental networking error
                debugPrint("error=\(error ?? "some error Comes" as! Error)")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {  // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print(response!)
                return
            }
            let responseString  = try! JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String : AnyObject]
            onCompletion(responseString, nil)
        }
        task.resume()
    }
    static func isPositionAvailable(latLng:CLLocationCoordinate2D, latLngArray:[CLLocationCoordinate2D]) ->Int{
        var availableAtIndex = -1
        for i in 0..<latLngArray.count{
            if(latLng.latitude == latLngArray[i].latitude && latLng.longitude == latLngArray[i].longitude ){
                availableAtIndex = i
                break
            }
        }
        return availableAtIndex
    }
    static func getNearbymarkers(position:CLLocationCoordinate2D,markers:[GMSMarker])->Int{
        var distanceArray = [Double]()
        for markers in markers{
            let distance = GMSGeometryDistance(markers.position, position)
            distanceArray.append(distance)
            debugPrint(markers.title!)
        }
        return distanceArray.index(of: distanceArray.min()!) ?? 0
    }
    static func setHoleShotDetails(par:Int,shots:Int)->(String,UIColor){
        var holeFinishStatus = String()
        var color = UIColor()
        switch shots-par{
        case -1:
            holeFinishStatus = "  Birdie  "
            color = UIColor.glfFlatBlue
            break
        case -2:
            holeFinishStatus = "  Eagle  "
            color = UIColor.glfFlatBlue
            break
        case -3:
            holeFinishStatus = "  Albatross  "
            color = UIColor.glfFlatBlue
            break
        case 0:
            holeFinishStatus = "  Par  "
            color = UIColor.glfFlatBlue
            break
        case 1:
            holeFinishStatus = "  Bogey  "
            color = UIColor.glfWarmGrey
            break
        case 2:
            holeFinishStatus = "  D. Bogey  "
            color = UIColor.glfWarmGrey
            break
        default:
            holeFinishStatus = " \(shots-par) Bogey "
            color = UIColor.glfRosyPink
        }
        return (holeFinishStatus,color)
    }
    static func returnLandedOnFullName(data:String)->(String,UIColor){
        var fullName = "Rough"
        var color = UIColor.glfRough
        if data == "G"{
            color = UIColor.glfGreen
            fullName = "Green"
        }else if data == "F" {
            color = UIColor.glfFairway
            fullName = "Fairway"
        }else if data == "GB" || data == "FB"{
            fullName = "Bunker"
            color = UIColor.glfBunker
        }
        else if data == "WH"{
            fullName = "Water H."
            color = UIColor.glfBluegreen
        }
        return (fullName,color)
    }
    static func coordInsideFairway(newPoint:CLLocationCoordinate2D, array:[CLLocationCoordinate2D],path:GMSMutablePath)->CLLocationCoordinate2D{
        
        let coordinate = array[BackgroundMapStats.nearByPoint(newPoint: newPoint, array: array)]
        blockRecursionIssue += 2
        let distance = GMSGeometryDistance(newPoint, coordinate)
        let headingAngle = GMSGeometryHeading(newPoint,coordinate)
        var nextPoint = GMSGeometryOffset(newPoint, distance+8.0, headingAngle)
        if(GMSGeometryContainsLocation(nextPoint, path, true)){
            return nextPoint
        }
        else{
            if(blockRecursionIssue > 200){
                return nextPoint
            }
            nextPoint = coordInsideFairway(newPoint: nextPoint, array: array, path: path)
        }
        return nextPoint
    }
    
    static func getPoints(hole:CLLocationCoordinate2D,greenPath:[CLLocationCoordinate2D],gir:Double,insideDistance:Double)->CLLocationCoordinate2D{
        var latLngArray = greenPath
        var greenHeadingAngle = 0.0
        var distance = 0.0
        var maxDistance = 0.0
        let generatedDistance = 0.0
        var distanceArray = [Double]()
        var offsetLatLong = CLLocationCoordinate2D()
        for i in 0..<latLngArray.count{
            distance = GMSGeometryDistance(hole,latLngArray[i])
            distanceArray.append(distance)
            if(maxDistance < distance){
                maxDistance = distance;
            }
        }
        var dX = 20.0
        if(insideDistance < 5){
            dX = 2.0 * insideDistance
        }
        let maximumDistance = insideDistance-dX > dX ? insideDistance-dX : dX
        let minimumDistance = insideDistance-dX < dX ? insideDistance-dX : dX
        
        let convertInside = Int(maximumDistance-minimumDistance)
        let randomGeneratedDistance = Int(arc4random_uniform(UInt32(convertInside))) + Int(minimumDistance)
        let randomGir = Double(arc4random_uniform(100))
        
        for _ in 0..<latLngArray.count{
            var randomHeading = Int(arc4random_uniform(UInt32(latLngArray.count - 1)))
            randomHeading += 1
            if(randomHeading == latLngArray.count){
                randomHeading = 0
            }
            if(randomGir<gir) {
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                if (insideDistance - maxDistance > 20) {
                    offsetLatLong = GMSGeometryOffset(hole,insideDistance, greenHeadingAngle)
                    break
                }
                
                if(generatedDistance<maxDistance){
                    if(distanceArray[randomHeading] > Double(randomGeneratedDistance)) {
                        greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                        offsetLatLong = GMSGeometryOffset(hole,Double(randomGeneratedDistance), greenHeadingAngle)
                        break
                    }
                }
                
                if (generatedDistance > maxDistance) {
                    greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                    offsetLatLong = GMSGeometryOffset(hole,(maxDistance - Double(arc4random_uniform(5)) > 0 ? 2:maxDistance -  Double(arc4random_uniform(5))), greenHeadingAngle)
                    break
                }
            }else{
                distance = GMSGeometryDistance(hole,latLngArray[randomHeading])
                greenHeadingAngle = GMSGeometryHeading(hole, latLngArray[randomHeading])
                offsetLatLong = GMSGeometryOffset(hole,Double(distance) + Double(arc4random_uniform(20)), greenHeadingAngle)
                break
            }
        }
        if(offsetLatLong.latitude == 0){
            offsetLatLong = GMSGeometryOffset(hole,insideDistance, Double(arc4random_uniform(360)))
        }
        return offsetLatLong
    }
    static func removeRepetedElement(curvedArray : [CLLocationCoordinate2D] )->[CLLocationCoordinate2D]{
        var uniqueArray = [CLLocationCoordinate2D]()
        
        if(!curvedArray.isEmpty){
            var lat = [CLLocationDegrees]()
            var lng = [CLLocationDegrees]()
            for i in 0..<curvedArray.count{
                lat.append(curvedArray[i].latitude)
                lng.append(curvedArray[i].longitude)
            }
            lat = lat.removeDuplicates()
            lng = lng.removeDuplicates()
            for i in 0..<lng.count{
                uniqueArray.append(CLLocationCoordinate2D(latitude: lat[i], longitude: lng[i]))
            }
        }
        return uniqueArray
    }
    static func imageOfButton(endingPoint: String)->UIImage{
        let btn = UIButton(frame:CGRect(x: 0, y: 0, width: 100, height: 30))
        btn.titleLabel?.font = UIFont(name:"SFProDisplay-Regular", size: 16)
        btn.setTitleColor(UIColor.glfWhite, for: .normal)
        btn.layer.cornerRadius = 15
        
        if endingPoint == "G"{
            btn.backgroundColor = UIColor.glfGreen
            btn.setTitle("Green", for: .normal)
        }else if endingPoint == "F" {
            btn.backgroundColor = UIColor.glfFairway
            btn.setTitle("Fairway", for: .normal)
        }else if endingPoint == "GB" || endingPoint == "FB"{
            btn.setTitle("Bunker", for: .normal)
            btn.backgroundColor = UIColor.glfBunker
        }else{
            btn.setTitle("Rough", for: .normal)
            btn.backgroundColor = UIColor.glfRough
        }
        return btn.screenshot()
    }

    static func getDistanceWithZoom(zoom:Float)->Double{
        var checkDistance:Double = 20
        if (zoom > 20) {
            checkDistance = 1
        } else if (zoom > 19.8 && zoom < 20) {
            checkDistance = 2
        } else if (zoom > 19.6 && zoom < 19.8) {
            checkDistance = 2
        } else if (zoom > 19.4 && zoom < 19.6) {
            checkDistance = 3
        } else if (zoom > 19.2 && zoom < 19.4) {
            checkDistance = 4
        } else if (zoom > 19 && zoom < 19.2) {
            checkDistance = 5
        } else if (zoom > 18.8 && zoom < 19) {
            checkDistance = 6
        } else if (zoom > 18.6 && zoom < 18.8) {
            checkDistance = 7
        } else if (zoom > 18.4 && zoom < 18.6) {
            checkDistance = 8
        } else if (zoom > 18.2 && zoom < 18.4) {
            checkDistance = 9
        } else if (zoom > 17 && zoom < 18.2) {
            checkDistance = 10
        } else if (zoom > 17.8 && zoom < 18) {
            checkDistance = 11
        } else if (zoom > 17.6 && zoom < 17.8) {
            checkDistance = 12
        } else if (zoom > 17.4 && zoom < 17.6) {
            checkDistance = 13
        } else if (zoom > 17.2 && zoom < 17.4) {
            checkDistance = 14
        } else if (zoom > 17 && zoom < 17.2) {
            checkDistance = 15
        } else if (zoom > 16.8 && zoom < 17) {
            checkDistance = 16
        } else if (zoom > 16.6 && zoom < 16.8) {
            checkDistance = 17
        } else if (zoom > 16.4 && zoom < 16.6) {
            checkDistance = 18
        } else if (zoom > 16.2 && zoom < 16.4) {
            checkDistance = 19
        } else if (zoom > 16 && zoom < 16.2) {
            checkDistance = 20
        }
        return checkDistance*3
    }
    static func sortAndShow(searchDataArr:[NSMutableDictionary],myLocation:CLLocation)->[NSMutableDictionary]{
        var searchArr = searchDataArr
        var indexArr = [Int]()
        var i = 0
        for data in searchArr{
            let latt = data.value(forKey: "Latitude") as! String
            let lng = data.value(forKey: "Longitude") as! String
            if(latt.count > 2) && (lng.count > 2){
                let coord = CLLocation(latitude: Double(latt)!, longitude: Double(lng)!)
                data.setValue(myLocation.distance(from: coord), forKey: "Distance")
            }else{
                indexArr.append(i)
                ref.child("invalidCourses").updateChildValues([data.value(forKey: "Id") as! String:true])
            }
            i += 1
        }
        for ind in indexArr{
            searchArr.remove(at: ind)
        }
        let sortedArr = searchArr.sorted{
            ($1.value(forKey: "Distance")) as! Double > ($0.value(forKey: "Distance")) as! Double
        }
        return sortedArr
    }
}

