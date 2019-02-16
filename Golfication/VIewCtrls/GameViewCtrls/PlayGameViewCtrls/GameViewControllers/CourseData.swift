//
//  CourseData.swift
//  Golfication
//
//  Created by Khelfie on 28/06/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import GoogleMaps
import FirebaseAuth

class CourseData:NSObject{
    var polygonArray = [[CLLocationCoordinate2D]]()
    var numberOfHoles = [(hole: Int,tee:[[CLLocationCoordinate2D]] ,fairway:[[CLLocationCoordinate2D]], green:[CLLocationCoordinate2D],fb:[[CLLocationCoordinate2D]],gb:[[CLLocationCoordinate2D]],wh:[[CLLocationCoordinate2D]],par:Int)]()
    var propertyArray = [Properties]()
    var centerPointOfTeeNGreen = [(tee:CLLocationCoordinate2D,fairway:CLLocationCoordinate2D,green:CLLocationCoordinate2D)]()
    var clubData = [(name:String,max:Int,min:Int)]()
    var clubs = ["Dr", "3w","5w","3i","4i","5i","6i","7i","8i","9i", "Pw","Sw","Lw","Pu","more"]
    var holeGreenDataArr = [GreenData]()
    var golfBagArray = NSMutableArray()
    var startingIndex : Int!
    var gameTypeIndex = 18
    var holeHcpWithTee = [(hole:Int,teeBox:[NSMutableDictionary])]()
    var isContinue = false
    func getGolfCourseDataFromFirebase(courseId:String){
//        let courseId = "course_99999999"
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseGolf(addedPath:courseId) { (snapshot) in
            let group = DispatchGroup()
            let completeDataDict = (snapshot.value as? NSDictionary)!
            var rangeFinderHoles = NSArray()
            var stableFordHoles = NSArray()
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
                }else if(key as! String == "par"){
                    if let count = value as? NSArray{
                        for i in 0..<count.count{
                            if let par = (count[i] as! NSMutableDictionary).value(forKey: "par") as? String {
                                self.numberOfHoles.append((hole: i+1, tee: [[CLLocationCoordinate2D]](), fairway: [[CLLocationCoordinate2D]](), green: [CLLocationCoordinate2D](), fb: [[CLLocationCoordinate2D]](), gb: [[CLLocationCoordinate2D]](), wh: [[CLLocationCoordinate2D]](),par:Int(par)!))
                            }else if let par = (count[i] as! NSMutableDictionary).value(forKey: "par") as? Int {
                                self.numberOfHoles.append((hole: i+1, tee: [[CLLocationCoordinate2D]](), fairway: [[CLLocationCoordinate2D]](), green: [CLLocationCoordinate2D](), fb: [[CLLocationCoordinate2D]](), gb: [[CLLocationCoordinate2D]](), wh: [[CLLocationCoordinate2D]](),par:par))
                            }
                        }
                    }
                }
                else if ((key as! String) == "rangefinder"){
                    let dict = value as! NSMutableDictionary
                    rangeFinderHoles = dict.value(forKey: "holes") as! NSArray
                }else if((key as! String) == "stableford"){
                    let dict = value as! NSMutableDictionary
                    stableFordHoles = dict.value(forKey: "holes") as! NSArray
                }
                group.leave()
            }            
            group.notify(queue: .main){
                if(self.propertyArray.isEmpty){
                    self.holeHcpWithTee.removeAll()
                    for i in 0..<rangeFinderHoles.count{
                        let dataDic = NSMutableDictionary()
                        dataDic.setObject((rangeFinderHoles[i] as AnyObject).object(forKey: "greenLat")!, forKey: "greenLat" as NSCopying)
                        dataDic.setObject((rangeFinderHoles[i] as AnyObject).object(forKey: "greenLng")!, forKey: "greenLng" as NSCopying)
                        let green = CLLocationCoordinate2D(latitude:dataDic.value(forKey: "greenLat") as! CLLocationDegrees, longitude:dataDic.value(forKey: "greenLng") as! CLLocationDegrees )
                        if let teeBoxes = (rangeFinderHoles[i] as AnyObject).object(forKey: "teeBoxes") as? NSArray{
                            dataDic.setObject(((teeBoxes[0] as AnyObject).object(forKey:"lat") as! Double), forKey: "teeLat" as NSCopying)
                            dataDic.setObject(((teeBoxes[0] as AnyObject).object(forKey:"lng") as! Double), forKey: "teeLong" as NSCopying)
                            if let hcp = (teeBoxes[0] as AnyObject).object(forKey:"hcp") as? Int{
                                dataDic.setObject(hcp, forKey: "hcp" as NSCopying)
                            }
                            var teeData = [NSMutableDictionary]()
                            for data in teeBoxes{
                                teeData.append(data as! NSMutableDictionary)
                            }
                            self.holeHcpWithTee.append((hole: i+1, teeBox: teeData))
                        }

                        let tee = CLLocationCoordinate2D(latitude:dataDic.value(forKey: "teeLat") as! CLLocationDegrees, longitude:dataDic.value(forKey: "teeLong") as! CLLocationDegrees )
                        
                        let distance = GMSGeometryDistance(tee, green)
                        let heading = GMSGeometryHeading(tee, green)
                        let fairway = GMSGeometryOffset(tee, distance*0.7, heading)
                        self.centerPointOfTeeNGreen.append((tee:tee, fairway:fairway , green:green))
                        if let _ = (rangeFinderHoles[i] as AnyObject).object(forKey: "frontLat") as? Double{
                            let front = CLLocationCoordinate2D(latitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "frontLat") as! Double, longitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "frontLng") as! Double)
                            
                            let center = CLLocationCoordinate2D(latitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "greenLat") as! Double, longitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "greenLng") as! Double)
                            let end = CLLocationCoordinate2D(latitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "backLat") as! Double, longitude: (rangeFinderHoles[i] as AnyObject).object(forKey: "backLng") as! Double)
                            let greenData = GreenData(front: front, center: center, back: end)
                            self.holeGreenDataArr.append(greenData)
                        }
                    }
                }
                
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
                                debugPrint("WH,\(j),\(i)")
                                self.numberOfHoles[j].wh.append(self.polygonArray[i])
                            }
                        }
                    }
                }
                if(self.centerPointOfTeeNGreen.isEmpty){
                    var i = 0
                    self.holeHcpWithTee.removeAll()
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
                        if(stableFordHoles.count  == self.numberOfHoles.count){
                            let teeBoxes = (stableFordHoles[i] as AnyObject).object(forKey: "teeBoxes") as! NSArray
                            var teeData = [NSMutableDictionary]()
                            for data in teeBoxes{
                                teeData.append(data as! NSMutableDictionary)
                            }
                            self.holeHcpWithTee.append((hole: i+1, teeBox: teeData))
                        }else if(rangeFinderHoles.count  == self.numberOfHoles.count){
                            let teeBoxes = (rangeFinderHoles[i] as AnyObject).object(forKey: "teeBoxes") as! NSArray
                            var teeData = [NSMutableDictionary]()
                            for data in teeBoxes{
                                teeData.append(data as! NSMutableDictionary)
                            }
                            self.holeHcpWithTee.append((hole: i+1, teeBox: teeData))
                        }
                        if !centerOfTee.isEmpty{
                            let centerTee = centerOfTee[indexOfMaxDistanceTee]
                            let centerOfGreen = BackgroundMapStats.middlePointOfListMarkers(listCoords:data.green)
                            let headingAngle = GMSGeometryHeading(centerTee, centerOfGreen)
                            let distance = GMSGeometryDistance(centerTee, centerOfGreen)
                            let fairWayPoint = GMSGeometryOffset(centerTee, distance*0.8, headingAngle)
                            self.centerPointOfTeeNGreen.append((tee: centerTee,fairway:fairWayPoint,green: centerOfGreen))
                        }
                        i += 1
                    }
                }
                
                if self.startingIndex != nil {
                    debugPrint(self.propertyArray.count)
                    debugPrint(self.centerPointOfTeeNGreen.count)
                    debugPrint(self.numberOfHoles.count)
                    debugPrint(self.gameTypeIndex)
                    debugPrint(self.startingIndex)
                    debugPrint(self.holeGreenDataArr.count)
                    debugPrint(self.holeHcpWithTee.count)
                    var temp = self.propertyArray
                    temp.removeAll()
                    if(self.numberOfHoles.count < self.gameTypeIndex){
                        var tempArr = self.propertyArray
                        var tempHoleArr = self.centerPointOfTeeNGreen
                        var tempNuOfHole = self.numberOfHoles
                        var temp = self.holeHcpWithTee
                        for data in self.holeHcpWithTee{
                            temp.append(data)
                        }
                        for data in self.propertyArray{
                            tempArr.append(data)
                        }
                        for data in self.centerPointOfTeeNGreen{
                            tempHoleArr.append(data)
                        }
                        var i = self.numberOfHoles.last!.hole
                        for data in self.numberOfHoles{
                            var newData = data
                            newData.hole = i+1
                            tempNuOfHole.append(newData)
                            i = i+1
                        }
                        self.numberOfHoles = tempNuOfHole
                        self.propertyArray = tempArr
                        self.centerPointOfTeeNGreen = tempHoleArr
                        self.holeHcpWithTee = temp
                    }else if (self.numberOfHoles.count > self.gameTypeIndex){
                        Constants.back9 = false
                        if (self.startingIndex > self.gameTypeIndex){
                            self.numberOfHoles.removeFirst(9)
                            if !self.centerPointOfTeeNGreen.isEmpty{
                                self.centerPointOfTeeNGreen.removeFirst(9)
                            }
                            if !self.holeHcpWithTee.isEmpty{
                                self.holeHcpWithTee.removeFirst(9)
                            }

                            Constants.back9 = true
                            for i in 0..<9{
                                for j in 0..<self.propertyArray.count{
                                    if self.propertyArray[j].hole == i+1{
                                        temp.append(self.propertyArray[j])
                                    }
                                }
                            }
                        }else{
                            self.numberOfHoles.removeLast(9)
                            if !self.centerPointOfTeeNGreen.isEmpty{
                                self.centerPointOfTeeNGreen.removeLast(9)
                            }
                            if !self.holeHcpWithTee.isEmpty{
                                self.holeHcpWithTee.removeLast(9)
                            }
                            for i in 9..<18{
                                for j in 0..<self.propertyArray.count{
                                    if self.propertyArray[j].hole == i+1{
                                        temp.append(self.propertyArray[j])
                                    }
                                }
                            }
                        }
                    }
                    self.propertyArray = temp
                }
                for i in 0..<self.numberOfHoles.count{
                    self.scoring.append((hole: self.numberOfHoles[i].hole, par: self.numberOfHoles[i].par,players:NSMutableDictionary()))
                }
                self.teeTypeArr.removeAll()
                if let players = Constants.matchDataDic.value(forKey: "players") as? NSMutableDictionary{
                    if let v = players.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSMutableDictionary{
                        var teeOfP = String()
                        var teeColorOfP = String()
                        var handicapOfP = Double()
                        if let tee = v.value(forKeyPath: "tee") as? String{
                            teeOfP = tee
                        }
                        if let teeColor = v.value(forKeyPath: "teeColor") as? String{
                            teeColorOfP = teeColor
                        }
                        if let hcp = v.value(forKeyPath: "handicap") as? String{
                            handicapOfP = Double(hcp)!
                        }
                        if(teeOfP != ""){
                            self.teeTypeArr.append((tee: teeOfP,color:teeColorOfP, handicap: handicapOfP))
                        }
                    }
                }
                self.getGolfBagData()
            }
        }
    }
    
    func getValidIndex(isNext:Bool,index:Int,max:Int,min:Int)->Int{
        var holeIndex = index
        if(self.gameTypeIndex < self.numberOfHoles.count){
            if(min < max){
                if(holeIndex >= min) && (holeIndex < max){
                    return holeIndex
                }else{
                    return isNext ? min : max-1
                }
            }else{
                if(holeIndex < 0){
                    holeIndex = numberOfHoles.count-1
                }else if(holeIndex == numberOfHoles.count){
                    holeIndex = 0
                }else if (holeIndex >= max){
                    holeIndex = min<=holeIndex ? holeIndex%numberOfHoles.count:min
                }else if (holeIndex <= min){
                    holeIndex = max == holeIndex ? min:holeIndex%numberOfHoles.count
                }
                return holeIndex
            }
        }else{
            return holeIndex%self.gameTypeIndex
        }
    }
    
    
    func getGolfBagData(){
        golfBagArray.removeAllObjects()
        FirebaseHandler.fireSharedInstance.getResponseFromFirebase(addedPath: "golfBag") { (snapshot) in
            if(snapshot.value != nil){
                self.golfBagArray = snapshot.value as! NSMutableArray
            }
            DispatchQueue.main.async(execute: {
                if self.golfBagArray.count > 0{
                    self.clubs.removeAll()
                    for i in 0..<self.golfBagArray.count{
                        if let dict = self.golfBagArray[i] as? NSDictionary{
                            self.clubs.append(dict.value(forKey: "clubName") as! String)
                        }
                        else{
                            let tempArray = snapshot.value as! NSMutableArray
                            var golfBagData = [String: NSMutableArray]()
                            for i in 0..<tempArray.count{
                                let golfBagDict = NSMutableDictionary()
                                golfBagDict.setObject("", forKey: "brand" as NSCopying)
                                golfBagDict.setObject("", forKey: "clubLength" as NSCopying)
                                golfBagDict.setObject(tempArray[i], forKey: "clubName" as NSCopying)
                                golfBagDict.setObject("", forKey: "loftAngle" as NSCopying)
                                golfBagDict.setObject(false, forKey: "tag" as NSCopying)
                                golfBagDict.setObject("", forKey: "tagName" as NSCopying)
                                golfBagDict.setObject("", forKey: "tagNum" as NSCopying)
                                self.golfBagArray.replaceObject(at: i, with: golfBagDict)
                                golfBagData = ["golfBag": self.golfBagArray]
                                self.clubs.append(tempArray[i] as! String)
                            }
                            if golfBagData.count>0{
                                ref.child("userData/\(Auth.auth().currentUser!.uid)/").updateChildValues(golfBagData)
                            }
                            break
                        }
                    }
                    var temp = [String]()
                    for cub in Constants.allClubs{
                        for clubs in self.clubs{
                            if (clubs == cub){
                                temp.append(clubs)
                                break
                            }
                            
                        }
                    }
                    self.clubs = temp
                }
                self.clubs.append("Pu")
                //                self.clubs.append("More")
                self.clubs = self.clubs.removeDuplicates()
                self.calculateTagWithClubNumber()
                self.updateMaxMin()
            })
        }
    }
    
    func updateMaxMin(){
        clubData.removeAll()
        for data in Constants.clubWithMaxMin where clubs.contains(data.name){
            clubData.append((name: data.name, max: data.max, min: data.min))
        }
        clubData.sort{($0).max > ($1).max}
        for i in 0..<clubData.count-1{
            if !(clubData[i].min == clubData[i+1].max+1) && (clubData[i].min>Constants.clubWithMaxMin[i+1].max+1){
                let diff = clubData[i].min - clubData[i+1].max+1
                clubData[i].max += diff/2
                clubData[i+1].min -= diff/2
                if(clubData[i+1].min < 0){
                    clubData[i+1].min = 0
                }
            }
        }
        debugPrint("clubs \(clubData)")
        if Constants.deviceGolficationX != nil{
            Constants.ble.golfBagArray = self.golfBagArray
            var centerPointOfTeeNGreenWithPar = [(tee:CLLocationCoordinate2D,fairway:CLLocationCoordinate2D,green:CLLocationCoordinate2D,par:Int)]()
            for i in 0..<centerPointOfTeeNGreen.count{
                centerPointOfTeeNGreenWithPar.append((tee: centerPointOfTeeNGreen[i].tee, fairway: centerPointOfTeeNGreen[i].fairway, green: centerPointOfTeeNGreen[i].green, par: numberOfHoles[i].par))
            }
            if Constants.fromDeviceMatch{
               Constants.fromDeviceMatch = false
                if !isContinue{
                    Constants.ble.courseData = self
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command3"), object: centerPointOfTeeNGreenWithPar)
                }
            }
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "continueCourseData"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "courseDataAPIFinished"), object: nil)
    }
    func calculateTagWithClubNumber(){
        Constants.tagClubNum.removeAll()
        let allClubs = ["Dr","3w","4w","5w","7w","1i","2i","3i","4i","5i","6i","7i","8i","9i","1h","2h","3h","4h","5h","6h","7h","Pw","Gw","Sw","Lw","Pu"]

        for j in 0..<self.golfBagArray.count{
            if let club = self.golfBagArray[j] as? NSMutableDictionary{
                if club.value(forKey: "tag") as! Bool{
                    let tagNumber = club.value(forKey: "tagNum") as! String
                    var num = 0
                    if tagNumber.contains("a") || tagNumber.contains("A") || tagNumber.contains("b") || tagNumber.contains("B") || tagNumber.contains("c") || tagNumber.contains("C") || tagNumber.contains("d") || tagNumber.contains("D") || tagNumber.contains("e") || tagNumber.contains("E") || tagNumber.contains("f") || tagNumber.contains("F"){
                        num = Int(tagNumber, radix: 16)!
                    }else{
                        num = Int(tagNumber)!
                    }
                    let clubName = club.value(forKey: "clubName") as! String
                    let clubNumber = allClubs.index(of: clubName)! + 1
                    Constants.tagClubNum.append((tag: num, club: clubNumber,clubName:clubName))
                }
            }
        }
    }
    var penaltyShots = [Bool]()
    var gir = Bool()
    var positionsOfCurveLines = [CLLocationCoordinate2D]()
    var positionsOfDotLine = [CLLocationCoordinate2D]()
    var teeTypeArr = [(tee:String,color:String,handicap:Double)]()
    var shotsDetails = [(club: String, distance: Double, strokesGained: Double, swingScore: String,endingPoint:String,penalty:Bool)]()
    var scoring = [(hole:Int,par:Int,players:NSMutableDictionary)]()
    func processShots(){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(Constants.matchId)/scoring") { (snapshot) in
            var scoringData = [NSMutableDictionary]()
            if let dict = snapshot.value as? [NSMutableDictionary]{
                scoringData = dict
            }
            DispatchQueue.main.async(execute: {
                var i = 0
                for data in scoringData{
                    if let playersData = data.value(forKey: "\(Auth.auth().currentUser!.uid)") as? NSMutableDictionary{
                        if i == self.scoring.count{
                            return
                        }else{
                            self.startProcessing(playersData: playersData, hole: i)
                        }
                    }
                    i += 1
                }

            })
        }
    }
    func processSingleShots(hole:Int){
        FirebaseHandler.fireSharedInstance.getResponseFromFirebaseMatch(addedPath: "matchData/\(Constants.matchId)/scoring/\(hole)/\(Auth.auth().currentUser!.uid)") { (snapshot) in
            var playersData = NSMutableDictionary()
            if let dict = snapshot.value as? NSMutableDictionary{
                playersData = dict
            }
            DispatchQueue.main.async(execute: {
                self.startProcessing(playersData:playersData,hole:hole)
            })
        }
    }

    func startProcessing(playersData:NSMutableDictionary,hole:Int){
        self.shotsDetails.removeAll()
        self.positionsOfCurveLines.removeAll()
        self.positionsOfDotLine.removeAll()
        self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[hole].tee)
        self.positionsOfDotLine.append(self.centerPointOfTeeNGreen[hole].green)
        debugPrint("hole:",hole)
        var wantToDrag = false
        var shots = [NSMutableDictionary]()
        let holeOut = playersData.value(forKey: "holeOut") as? Bool ?? false
        let isSwing = playersData.value(forKey: "swing") as? Bool ?? true
        if let sho = playersData.value(forKey: "shots") as? NSArray, isSwing{
            wantToDrag = sho.count > 1 ? true:false
            if holeOut && sho.count == 1{
                wantToDrag = true
            }
            for i in 0..<sho.count{
                let shot = sho[i] as! NSMutableDictionary
                if let dat = shot.value(forKey: "clubDetected") as? Bool{
                    if !dat{
                        let latLng = CLLocationCoordinate2D(latitude: shot.value(forKey: "lat1") as! Double, longitude: shot.value(forKey: "lng1") as! Double)
                        var lie = self.callFindPositionInsideFeature(position: latLng, holeIndex: hole)
                        let distance = GMSGeometryDistance(latLng, self.centerPointOfTeeNGreen[hole].green)
                        if i == 0{
                            lie = "T"
                        }
                        let recommendedClub = self.clubReco(dist: distance, lie: lie)
                        shot.setValue(recommendedClub, forKey: "club")
                    }
                    shots.append(shot)
                }else{
                    shots.append(shot)
                }
            }
            
            var i = 0
            self.penaltyShots.removeAll()
            for data in shots{
                let distance = data.value(forKey: "distance") as? Double
                let club = data.value(forKey: "club") as! String
                let strokGaind = data.value(forKey: Constants.strkGainedString[Constants.skrokesGainedFilter]) as? Double
                let endingPoints = data.value(forKey: "end") as? String
                let penalty = data.value(forKey: "penalty") as! Bool
                self.penaltyShots.append(penalty)
                let startingPoint = data.value(forKey: "start") as? String
                self.shotsDetails.append((club: club, distance: distance ?? 0.0, strokesGained: strokGaind ?? 0.0, swingScore: startingPoint ?? "calculating",endingPoint:endingPoints ?? "calculationg ",penalty:penalty))
                self.positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: data.value(forKey: "lat1") as! CLLocationDegrees, longitude: data.value(forKey: "lng1") as! CLLocationDegrees))
                self.positionsOfDotLine[0] = (self.positionsOfCurveLines.last!)
                if(holeOut) && i == shots.count-1{
                    if(data.value(forKey: "lat2") != nil){
                        self.positionsOfCurveLines.append(CLLocationCoordinate2D.init(latitude: data.value(forKey: "lat2") as! CLLocationDegrees, longitude: data.value(forKey: "lng2") as! CLLocationDegrees))
                    }else{
                        self.positionsOfCurveLines.append(self.centerPointOfTeeNGreen[hole].green)
                    }
                }
                i += 1
            }
            
            playersData.setValue(shots, forKey: "shots")
            let playerDict = NSMutableDictionary()
            playerDict.setObject(playersData, forKey: Auth.auth().currentUser!.uid as NSCopying)
            if let scoring = Constants.matchDataDic.value(forKey: "scoring") as? NSArray{
                let sco = scoring
                (sco[hole] as! NSMutableDictionary).setValue(playersData, forKey: Auth.auth().currentUser!.uid)
                Constants.matchDataDic.setValue(sco, forKey: "scoring")
            }
            self.scoring[hole].players.setValue(playersData, forKey: Auth.auth().currentUser!.uid)
            ref.child("matchData/\(Constants.matchId)/scoring/\(hole)/\(Auth.auth().currentUser!.uid)/").updateChildValues(["swing":false] as [AnyHashable : Any])
            if wantToDrag{
                for k in 0..<shots.count{
                    if(k == 0){
                        self.uploadStatsWithDragging(shot: 1,playerId: Auth.auth().currentUser!.uid,holeIndex:hole,isDraggingMarker:true,holeOutFlag:holeOut)
                    }
                    else if(k == self.positionsOfCurveLines.count-1){
                        self.uploadStatsWithDragging(shot: k , playerId: Auth.auth().currentUser!.uid,holeIndex:hole,isDraggingMarker:true,holeOutFlag:holeOut)
                    }
                    else{
                        self.uploadStatsWithDragging(shot: k, playerId: Auth.auth().currentUser!.uid,holeIndex:hole,isDraggingMarker:true,holeOutFlag:holeOut)
                        self.uploadStatsWithDragging(shot: k + 1, playerId: Auth.auth().currentUser!.uid,holeIndex:hole,isDraggingMarker:true,holeOutFlag:holeOut)
                    }
                }
            }
            UIApplication.shared.keyWindow?.makeToast("Processing Hole \(hole+1)")
        }
    }
    
    
    func uploadStatsWithDragging(shot:Int,playerId:String,holeIndex:Int,isDraggingMarker:Bool,holeOutFlag:Bool){
        let girDict = NSMutableDictionary()
        let faiDict = NSMutableDictionary()
        if(shot==1) && (positionsOfCurveLines.count > 1){
            gir = false
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: holeIndex) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
            if(self.scoring[holeIndex].par > 3){
                var fairwayHitOrMiss = ""
                if(callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: holeIndex) != "F"){
                    fairwayHitOrMiss = isFairwayHitOrMiss(position: positionsOfCurveLines[shot], holeOutFlag: holeOutFlag,holeIndex: holeIndex)
                }
                else{
                    fairwayHitOrMiss = "H"
                }
                faiDict.setObject(fairwayHitOrMiss, forKey: "fairway" as NSCopying)
            }
            ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/").updateChildValues(faiDict as! [AnyHashable : Any])
            let drivDistDict = NSMutableDictionary()
            if(self.scoring[holeIndex].par>3){
                let drivingDistance = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])*Constants.YARD
                drivDistDict.setObject(drivingDistance.rounded(toPlaces: 2), forKey: "drivingDistance" as NSCopying)
            }
            ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/").updateChildValues(drivDistDict as! [AnyHashable : Any])
            
        }
        else if(shot == 2)&&(!gir)&&(self.scoring[holeIndex].par>3){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: holeIndex) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        else if(shot == 3)&&(!gir)&&(self.scoring[holeIndex].par>4){
            gir = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: holeIndex) == "G" ? true:false
            if(!isDraggingMarker) && shotsDetails.count > shot-1{
                gir = shotsDetails[shot-1].endingPoint == "G" ? true:false
            }
            girDict.setObject(gir, forKey: "gir" as NSCopying)
        }
        
        
        if(holeOutFlag) && shot == positionsOfCurveLines.count-1{
            uploadChipUpNDown(playerId: playerId, holeIndex: holeIndex)
            uploadSandUpNDown(playerId: playerId, holeIndex: holeIndex)
            uploadPutting(playerId: playerId, holeIndex: holeIndex)
            self.uploadPenalty(playerId: playerId,holeIndex:holeIndex)
            if(!self.teeTypeArr.isEmpty){
                self.uploadStableFordPints(playerId: playerId, holeIndex: holeIndex)
            }
        }
        
        uploadApproachAndApproachShots(playerId: playerId,holeIndex:holeIndex)
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/").updateChildValues(girDict as! [AnyHashable : Any])
        let shotsDict = self.scoring[holeIndex].players.value(forKey: playerId) as! NSMutableDictionary
        if var shotsValue = shotsDict.value(forKey: "shots") as? [NSMutableDictionary]{
            if(shot-1 < shotsValue.count){
                let clubValue = shotsValue[shot-1].value(forKey: "club") as! String
                let isPenaltyShot = shotsValue[shot-1].value(forKey: "penalty") as! Bool
                shotsValue[shot-1] = self.getShotDetails(shot:shot,club:clubValue,isPenalty: isPenaltyShot, hole: holeIndex,isDraggingMarker:isDraggingMarker, holeOutFlag: holeOutFlag)
                shotsDict.setValue(shotsValue, forKey: "shots")
                self.scoring[holeIndex].players.setValue(shotsDict, forKey: playerId)
                ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/shots/\(shot-1)").updateChildValues(shotsValue[shot-1] as! [AnyHashable : Any])
            }
        }
    }
    func uploadStableFordPints(playerId:String,holeIndex:Int){
        var strokes = Int()
        if let scoringDict = self.scoring[holeIndex].players.value(forKey: playerId) as? NSMutableDictionary{
            if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                strokes = scoreShots.count
            }
        }
        let par = scoring[holeIndex].par
        let courseHCP = Int(self.calculateTotalExtraShots(playerID: playerId))
        let temp = courseHCP/18
        var totalShotsInThishole = temp+par
        let hcp = self.getHCPValue(playerID: playerId, holeNo: self.scoring[holeIndex].hole)
        if (courseHCP - temp*18 >= hcp) {
            totalShotsInThishole += 1;
        }
        var sbPoint = totalShotsInThishole - strokes + 2
        if sbPoint<0 {
            sbPoint = 0
        }
        let netScore = strokes - (totalShotsInThishole - par)
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/stableFordPoints").setValue(sbPoint)
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/netScore").setValue(netScore)
    }
    private func getHCPValue(playerID:String,holeNo:Int)->Int{
        var hcp = 0
        for tee in self.holeHcpWithTee{
            if tee.hole == holeNo{
                for data in tee.teeBox {
                    if (data.value(forKey: "teeType") as! String) == (self.teeTypeArr[0].tee).lowercased() && (data.value(forKey: "teeColorType") as! String) == (self.teeTypeArr[0].color).lowercased(){
                        hcp = data.value(forKey:"hcp") as? Int ?? 0
                        break
                    }
                }
                break
            }
        }
        return hcp
    }
    func calculateTotalExtraShots(playerID:String)->Double{
        var slopeIndex = 0
        for data in Constants.teeArr{
            if(data.type.lowercased() == self.teeTypeArr[0].tee.lowercased()) && (data.name.lowercased() == self.teeTypeArr[0].color.lowercased()){
                break
            }
            slopeIndex += 1
        }
        let data = (self.teeTypeArr[0].handicap * Double(Constants.teeArr[slopeIndex].slope)!)
        return (Double(data / 113)).rounded()
    }
    func uploadApproachAndApproachShots(playerId:String,holeIndex:Int){
        var approachDistance = 0.0
        let appDistDict = NSMutableDictionary()
        for i in 0..<positionsOfCurveLines.count{
            approachDistance = GMSGeometryDistance(positionsOfCurveLines[i],self.centerPointOfTeeNGreen[holeIndex].green)*Constants.YARD
            if(approachDistance<200 && approachDistance != 0){
                appDistDict.setObject(approachDistance.rounded(toPlaces: 2), forKey: "approachDistance" as NSCopying)
                break
            }
        }
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/").updateChildValues(appDistDict as! [AnyHashable : Any])
    }
    
    func uploadPenalty(playerId:String,holeIndex:Int){
        var putting = Int()
            if let scoringDict = self.scoring[holeIndex].players.value(forKey: playerId) as? NSMutableDictionary{
                if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                    for data in scoreShots{
                        let dataDict = data as! NSMutableDictionary
                        if((dataDict.value(forKey: "penalty") as! Bool) == true){
                            putting += 1
                        }
                    }
                }
            }
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/penaltyCount").setValue(putting)
    }
    func isFairwayHitOrMiss(position:CLLocationCoordinate2D,holeOutFlag:Bool,holeIndex:Int)->String{
        var fairwayDetails = ""
        var headingAngleOfTeeToGreen = 0.0
        if(holeOutFlag){
            headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfCurveLines.first!, position: position,holeIndex:holeIndex)
        }
        else{
            if(positionsOfDotLine.count != 0){
                if(positionsOfCurveLines.isEmpty){
                    headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfDotLine.first!, position: position, holeIndex: holeIndex)
                }else{
                    headingAngleOfTeeToGreen = getPointHeading(starting: positionsOfCurveLines.first!, position: position, holeIndex: holeIndex)
                }
            }
        }
        
        var headingAngleOfTeeToFairway = 0.0
        if(positionsOfCurveLines.isEmpty){
            headingAngleOfTeeToFairway = GMSGeometryHeading(positionsOfDotLine.first!, position)
        }
        else{
            headingAngleOfTeeToFairway = GMSGeometryHeading(positionsOfCurveLines.first!, position)
        }
        if(headingAngleOfTeeToFairway < headingAngleOfTeeToGreen){
            fairwayDetails = "L"
        }
        else{
            fairwayDetails = "R"
        }
        return fairwayDetails
    }
    func getPointHeading(starting:CLLocationCoordinate2D,position:CLLocationCoordinate2D,holeIndex:Int)->Double{
        var heading = 0.0
        if !((self.numberOfHoles[holeIndex]).fairway).isEmpty{
            var nearPoint = [CLLocationCoordinate2D]()
            var distance = [Double]()
            for data in ((self.numberOfHoles[holeIndex]).fairway){
                nearPoint.append(data[(BackgroundMapStats.nearByPoint(newPoint: position, array: data))])
                distance.append(GMSGeometryDistance(position, nearPoint.last!))
            }
            let min = distance.min()!
            let index = distance.firstIndex(of: min)!
            let finalNearbyPoint = nearPoint[index]
            heading = GMSGeometryHeading(starting, finalNearbyPoint)
        }
        return heading
    }
    func uploadChipUpNDown(playerId : String,holeIndex:Int){
        var appDistance = Double()
        var chipUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], self.numberOfHoles[holeIndex].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: self.numberOfHoles[holeIndex].green)])*Constants.YARD
            if(appDistance<70){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i], holeIndex: holeIndex) != "GB" ){
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
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/chipUpDown").setValue(chipUpDown)
    }
    func uploadSandUpNDown(playerId : String,holeIndex:Int){
        var appDistance = Double()
        var sandUpDown : Bool!
        for i in 0..<positionsOfCurveLines.count-1{
            appDistance = GMSGeometryDistance(positionsOfCurveLines[i], self.numberOfHoles[holeIndex].green[BackgroundMapStats.nearByPoint(newPoint: positionsOfCurveLines[i], array: self.numberOfHoles[holeIndex].green)])*Constants.YARD
            if(appDistance<70){
                if((positionsOfCurveLines.count-1 == i+2 || positionsOfCurveLines.count-1 == i+1) && callFindPositionInsideFeature(position:positionsOfCurveLines[i], holeIndex: holeIndex) == "GB" ){
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
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/sandUpDown").setValue(sandUpDown)
    }
    func getShotDetails(shot:Int,club:String,isPenalty:Bool,hole:Int,isDraggingMarker:Bool,holeOutFlag:Bool)->NSMutableDictionary{
        //        currentShotsDetails.removeAll()
        let shotDictionary = NSMutableDictionary()
        let shot = shot == 0 ? 1 : shot
        var start = String()
        var end = String()
        shotDictionary.setObject(positionsOfCurveLines[shot-1].latitude, forKey: "lat1" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot-1].longitude, forKey: "lng1" as NSCopying)
        shotDictionary.setObject(club.trim(), forKey: "club" as NSCopying)
        shotDictionary.setObject(isPenalty, forKey: "penalty" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].latitude, forKey: "lat2" as NSCopying)
        shotDictionary.setObject(positionsOfCurveLines[shot].longitude, forKey: "lng2" as NSCopying)
        if(shot == 1){
            shotDictionary.setObject("T", forKey: "start" as NSCopying)
            start = "T"
        }
        else{
            shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot-1], holeIndex: hole), forKey: "start" as NSCopying)
            start = callFindPositionInsideFeature(position:positionsOfCurveLines[shot-1], holeIndex: hole)
            if(start == "WH"){
                start = "R"
                shotDictionary.setObject(start, forKey: "start" as NSCopying)
            }
        }
        shotDictionary.setObject(callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: hole), forKey: "end" as NSCopying)
        end = callFindPositionInsideFeature(position:positionsOfCurveLines[shot], holeIndex: hole)
        if(end == "WH"){
            end = "R"
            shotDictionary.setObject(end, forKey: "end" as NSCopying)
        }

        let distanceBwShots = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines[shot])
        var distanceBwHole0 = Double()
        var distanceBwHole1 = Double()
        if(holeOutFlag){
            distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfCurveLines.last!)
            distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfCurveLines.last!)
        }
        else{
            distanceBwHole1 = GMSGeometryDistance(positionsOfCurveLines[shot], positionsOfDotLine.last!)
            distanceBwHole0 = GMSGeometryDistance(positionsOfCurveLines[shot-1], positionsOfDotLine.last!)
        }
        shotDictionary.setObject((distanceBwShots*Constants.YARD).rounded(toPlaces:2), forKey: "distance" as NSCopying)
        shotDictionary.setObject((distanceBwHole0*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole0" as NSCopying)
        shotDictionary.setObject((distanceBwHole1*Constants.YARD).rounded(toPlaces:2), forKey: "distanceToHole1" as NSCopying)
        start = BackgroundMapStats.setStartingEndingChar(str:start)
        end = BackgroundMapStats.setStartingEndingChar(str:end)
        let shotCount = positionsOfCurveLines.count-1
        if(end == "G"){
            end = "G\(Int((distanceBwHole1*Constants.YARD*3).rounded()))"
        }else{
            end = "\(end)\(Int((distanceBwHole1*Constants.YARD).rounded()))"
        }
        if(start == "G"){
            start = "G\(Int((distanceBwHole0*Constants.YARD*3).rounded()))"
        }else{
            start = "\(start)\(Int((distanceBwHole0*Constants.YARD).rounded()))"
        }
        if(Int((distanceBwHole0*Constants.YARD).rounded()) == 0){
            start = "G1"
        }else if(Int((distanceBwHole0*Constants.YARD).rounded()) > 600){
            start = "\(start)600"
        }else if (Int((distanceBwHole0*Constants.YARD).rounded()) < 100) && shotCount == 0{
            start = "\(start)100"
        }
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
        for i in 0..<Constants.strkGainedString.count{
                var strkGnd = Double()
                var startGained = Double()
                var endGained = Double()
                if(Constants.strokesGainedDict[i].value(forKey: start) != nil){
                    startGained = Constants.strokesGainedDict[i].value(forKey: start) as! Double
                }
                if(Constants.strokesGainedDict[i].value(forKey: end) != nil){
                    endGained = Constants.strokesGainedDict[i].value(forKey: end) as! Double
                }
                strkGnd = startGained - endGained - 1
            strkGnd = strkGnd - Double(numberOfPenalty)
            shotDictionary.setObject(strkGnd, forKey: Constants.strkGainedString[i] as NSCopying)
        }
        shotDictionary.setObject(coordLeftOrRight(start:positionsOfCurveLines[shot-1],end:positionsOfCurveLines[shot], holeOutFlag: holeOutFlag), forKey: "heading" as NSCopying)
        return shotDictionary
    }
    func coordLeftOrRight(start:CLLocationCoordinate2D,end:CLLocationCoordinate2D,holeOutFlag:Bool)->String{
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
    func callFindPositionInsideFeature(position:CLLocationCoordinate2D,holeIndex:Int)->String{
        var featureName = "R"
        for data in self.numberOfHoles[holeIndex].fairway{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "F"
                break
            }
        }
        for data in self.numberOfHoles[holeIndex].gb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "GB"
                break
            }
        }
        for data in self.numberOfHoles[holeIndex].fb{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "FB"
                break
            }
        }
        var allWaterHazard = [[CLLocationCoordinate2D]]()
        for i in 0..<self.numberOfHoles.count{
            for wh in self.numberOfHoles[i].wh{
                allWaterHazard.append(wh)
            }
        }
        for data in allWaterHazard{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "WH"
                break
            }
        }
        for data in self.numberOfHoles[holeIndex].tee{
            if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature: data)){
                featureName = "T"
                break
            }
        }
        if(BackgroundMapStats.findPositionOfPointInside(position: position, whichFeature:self.numberOfHoles[holeIndex].green)){
            featureName = "G"
        }
        return featureName
    }
    func  clubReco(dist:Double,lie:String)->String {
        if (lie.trim() == "G"){
            return " Pu";
        }else {
            var index = 0
            var i2 = 0
            var minX = 1000000.0
            var preferredClubs = [String]()
            for i in 0..<self.clubData.count {
                if (!self.clubs.contains(self.clubData[i].name)){ continue}
                if (self.clubData[i].name == "Pu"){continue}
                if (self.clubData[i].name == "Dr") &&
                    (lie != "T"){continue}
                let max = Double(self.clubData[i].max)
                let min = Double(self.clubData[i].min)
                var x = 0.0
                if (dist >= max) {
                    x = dist - max;
                    preferredClubs.append(" \(self.clubData[i].name)")
                } else if (dist <= min) {
                    x = min - dist;
                    preferredClubs.append(" \(self.clubData[i].name)")
                } else if (dist >= min && dist <= max) {
                    preferredClubs.append(" \(self.clubData[i].name)")
                }
                if (x < minX) {
                    index = i2;
                    minX = x;
                }
                i2 = i2+1
            }
            return preferredClubs[index]
        }
    }
    func uploadPutting(playerId:String,holeIndex:Int){
        var putting = Int()
        if let scoringDict = self.scoring[holeIndex].players.value(forKeyPath: playerId) as? NSMutableDictionary{
            if let scoreShots = (scoringDict.value(forKey: "shots") as? NSArray){
                for data in scoreShots{
                    let dataDict = data as! NSMutableDictionary
                    if((dataDict.value(forKey: "club") as! String).trim() == "Pu"){
                        putting += 1
                    }
                }
            }
        }
        ref.child("matchData/\(Constants.matchId)/scoring/\(holeIndex)/\(playerId)/putting").setValue(putting)
    }
}
class clubTableViewCell : UITableViewCell{
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}
