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
//                    let min = (self.startingIndex%self.gameTypeIndex)-1
//                    let max = self.numberOfHoles.count-1
                    
//                    if(self.numberOfHoles.count > self.gameTypeIndex) && self.startingIndex+self.gameTypeIndex-1 <= self.numberOfHoles.count{
//                        max = (self.startingIndex+self.gameTypeIndex) - 1
//                    }else if self.startingIndex+self.gameTypeIndex-1 > self.numberOfHoles.count{
//                        if(self.gameTypeIndex < self.numberOfHoles.count){
//                            max =  (self.startingIndex+self.gameTypeIndex-1) - self.numberOfHoles.count
//                        }
//                    }
//                    var temp = self.propertyArray
//                    temp.removeAll()
//                    var newTemp = self.centerPointOfTeeNGreen
//                    newTemp.removeAll()
//                    var tempholeGreenDataArr = [GreenData]()
//                    var tempNumofHole = self.numberOfHoles
//                    tempNumofHole.removeAll()
//                    var hcpData = self.holeHcpWithTee
//                    hcpData.removeAll()
                    
//                    for i in self.startingIndex-1..<self.gameTypeIndex+self.startingIndex-1{
//                        debugPrint("index:",i)
//                        debugPrint("validIndex:",self.getValidIndex(isNext: true, index: i, max: max, min: min))
//                        let newIndex = self.getValidIndex(isNext: true, index: i, max: max, min: min)
//                        for j in 0..<self.propertyArray.count{
//                            if self.propertyArray[j].hole == newIndex+1{
//                                temp.append(self.propertyArray[j])
//                            }
//                        }
//                        if !self.centerPointOfTeeNGreen.isEmpty{
//                            if newIndex < self.centerPointOfTeeNGreen.count{
//                                newTemp.append(self.centerPointOfTeeNGreen[newIndex])
//                            }
//                        }
//                        if(!self.holeGreenDataArr.isEmpty){
//                            tempholeGreenDataArr.append(self.holeGreenDataArr[newIndex])
//                        }
//                        tempNumofHole.append(self.numberOfHoles[newIndex])
//                        if(!self.holeHcpWithTee.isEmpty){
//                            self.holeHcpWithTee[newIndex].hole = newIndex+1
//                            hcpData.append(self.holeHcpWithTee[newIndex])
//                        }
//                    }
//                    if(!newTemp.isEmpty){
//                        self.centerPointOfTeeNGreen = newTemp
//                        self.propertyArray = temp
//
//                        self.holeGreenDataArr = tempholeGreenDataArr
//                        self.numberOfHoles = tempNumofHole
//                        self.holeHcpWithTee = hcpData
//                    }
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
            Constants.ble.isPracticeMatch = false
            Constants.ble.golfBagArray = self.golfBagArray
            var centerPointOfTeeNGreenWithPar = [(tee:CLLocationCoordinate2D,fairway:CLLocationCoordinate2D,green:CLLocationCoordinate2D,par:Int)]()
            for i in 0..<centerPointOfTeeNGreen.count{
                centerPointOfTeeNGreenWithPar.append((tee: centerPointOfTeeNGreen[i].tee, fairway: centerPointOfTeeNGreen[i].fairway, green: centerPointOfTeeNGreen[i].green, par: numberOfHoles[i].par))
            }
            if Constants.fromDeviceMatch{
               Constants.fromDeviceMatch = false
               NotificationCenter.default.post(name: NSNotification.Name(rawValue: "command3"), object: centerPointOfTeeNGreenWithPar)
            }
        }
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
