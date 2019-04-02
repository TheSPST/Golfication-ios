//
//  Utility.swift
//  DistanceIntents
//
//  Created by Rishabh Sood on 27/02/19.
//  Copyright © 2019 Khelfie. All rights reserved.
//

import UIKit
import CoreLocation
import CoreData
class DistanceUtil: NSObject {
    let context = CoreDataStorage.mainQueueContext()
    var nearbuyPointOfGreen : CLLocation!
    var flagPointOfGreen  : CLLocation!
    var endPointOfGreen  : CLLocation!
    var distanceToFront  : Double!
    var distanceToCenter  : Double!
    var distanceToBack  : Double!
    var textMsg  : String!
    var currentLocation  : CLLocation!
    var courseName : String!
    var userName : String!
    var imageUrl : String!
    var holeIndex : Int!
    var timesta : Int64!
    var distanceUnit = Int()
    var Timestamp: Int64 {
        return Int64(NSDate().timeIntervalSince1970*1000)
    }

    func writeHoleIndex(cDetails:CurrentHoleEntity){
        holeIndex = Int(cDetails.holeIndex)
        timesta = cDetails.timestamp
    }
    func writeDistanceUnit(cDetails:DistanceUnitEntity){
        distanceUnit = Int(cDetails.unit)
    }
    
    func writeCourseDetails(cDetails:CourseDetailsEntity){
        courseName = cDetails.cName
        userName = cDetails.uName
        imageUrl = cDetails.imgUrl
    }
    func getHoleNum(location:CLLocation,greeDisArr:[GreenDistanceEntity],teeArr:[TeeDistanceEntity],isMap:Bool=false)->String{
        var greenWiseData = [[CLLocation]]()
        var holeWiseData = [CLLocation]()
        currentLocation = location
        for _ in 0..<teeArr.count{
            greenWiseData.append([CLLocation]())
            holeWiseData.append(CLLocation())
        }
        for data in greeDisArr{
            let nextPoint = CLLocation(latitude: data.lat, longitude: data.lng)
            greenWiseData[Int(data.greeNum)].append(nextPoint)
        }
        for i in 0..<teeArr.count{
            let nextPoint = CLLocation(latitude: teeArr[i].lat, longitude: teeArr[i].lng)
            holeWiseData[i] = nextPoint
        }
//        var DistanceArr = [Double]()
//        for i in 0..<holeWiseData.count{
//            DistanceArr.append(holeWiseData[i].distance(from: location))
//            DistanceArr.append(greenWiseData[i].first!.distance(from: location))
//        }
        let index = self.holeIndex! //!= nil ? self.holeIndex!*2 : DistanceArr.firstIndex(of: DistanceArr.min()!)!
//        index = index/2
        debugPrint("\(index)")
//        let diff = (Timestamp/1000 - self.timesta!/1000)
        nearbuyPointOfGreen = greenWiseData[index][nearByPoint(newPoint: location, array: greenWiseData[index],isMin:true)]
        flagPointOfGreen = middlePointOfListMarkers(listCoords: greenWiseData[index])
        endPointOfGreen = greenWiseData[index][nearByPoint(newPoint: location, array: greenWiseData[index],isMin:false)]
        distanceToFront = nearbuyPointOfGreen.distance(from: location)
        distanceToCenter = flagPointOfGreen.distance(from: location)
        distanceToBack = endPointOfGreen.distance(from: location)
        distanceToCenter =  distanceUnit == 0 ? distanceToCenter*1.09361 : distanceToCenter
        let sufffix = distanceUnit == 0 ? "yards":"meter"
        textMsg = "You are \(Int(distanceToCenter)) \(sufffix) from the green on hole \(index+1)"
        if !isMap{
            self.storeCalledByUser(hole: index+1, lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
        return textMsg
    }
    func storeCalledByUser(hole:Int,lat:Double,lng:Double){
        context.performAndWait{ () -> Void in
            let calledByUserEntity = (NSEntityDescription.insertNewObject(forEntityName: "CalledByUserEntity", into: context) as! CalledByUserEntity)
            calledByUserEntity.timestamp = Timestamp
            calledByUserEntity.lat = lat
            calledByUserEntity.lng = lng
            calledByUserEntity.hole = Int16(hole)
            CoreDataStorage.saveContext(context)
        }
    }
    func getHoleNumRF(location:CLLocation,rfHole:[FrontBackDistanceEntity],teeArr:[TeeDistanceEntity],isMap:Bool=false)->String{
        currentLocation = location
        var holeWiseData = [CLLocation]()
        var greenWiseData = [[CLLocation]]()
        for _ in 0..<teeArr.count{
            holeWiseData.append(CLLocation())
            greenWiseData.append([CLLocation]())
        }
        for i in 0..<rfHole.count{
            let data = rfHole[i]
            let frontLatLng = CLLocation(latitude: data.frontLat, longitude: data.frontLng)
            let centerLatLng = CLLocation(latitude: data.centerLat, longitude: data.centerLng)
            let backLatLng = CLLocation(latitude: data.backLat, longitude: data.backLng)
            greenWiseData[i].append(centerLatLng)
            greenWiseData[i].append(frontLatLng)
            greenWiseData[i].append(backLatLng)
        }
        for i in 0..<teeArr.count{
            let nextPoint = CLLocation(latitude: teeArr[i].lat, longitude: teeArr[i].lng)
            holeWiseData[i] = nextPoint
        }
//        var DistanceArr = [Double]()
//        for i in 0..<holeWiseData.count{
//            DistanceArr.append(holeWiseData[i].distance(from: location))
//            DistanceArr.append(greenWiseData[i].first!.distance(from: location))
//        }
        let index = self.holeIndex! //!= nil ? self.holeIndex!*2 : DistanceArr.firstIndex(of: DistanceArr.min()!)!
//        index = index/2
//        debugPrint("\(index)")
//        let diff = (Timestamp/1000 - self.timesta!/1000)
        nearbuyPointOfGreen = greenWiseData[index][nearByPoint(newPoint: location, array: greenWiseData[index],isMin:true)]
        flagPointOfGreen = middlePointOfListMarkers(listCoords: greenWiseData[index])
        endPointOfGreen = greenWiseData[index][nearByPoint(newPoint: location, array: greenWiseData[index],isMin:false)]
        distanceToFront = nearbuyPointOfGreen.distance(from: location)
        distanceToCenter = flagPointOfGreen.distance(from: location)
        distanceToBack = endPointOfGreen.distance(from: location)
        distanceToCenter =  distanceUnit == 0 ? distanceToCenter*1.09361 : distanceToCenter
        let sufffix = distanceUnit == 0 ? "yards":"meter"
        textMsg = "You are \(Int(distanceToCenter)) \(sufffix) from the green on hole \(index+1)"
        //        if diff > 5*60{
//            textMsg = "please open app to update your current hole."
//        }
        if !isMap{
            self.storeCalledByUser(hole: index+1, lat: location.coordinate.latitude, lng: location.coordinate.longitude)
        }
        return textMsg
    }
    func middlePointOfListMarkers(listCoords: [CLLocation]) -> CLLocation{
        var x = 0.0
        var y = 0.0
        var z = 0.0
        
        for coordinate in listCoords{
            let lat = (coordinate.coordinate.latitude / 180.0 * Double.pi)
            let lon = (coordinate.coordinate.longitude / 180.0 * Double.pi)
            x = x + cos(lat) * cos(lon)
            y = y + cos(lat) * sin(lon);
            z = z + sin(lat);
        }
        x = x/Double((listCoords.count))
        y = y/Double((listCoords.count))
        z = z/Double((listCoords.count))
        
        let resultLon = atan2(y, x)
        let resultHyp = sqrt(x*x+y*y)
        let resultLat = atan2(z, resultHyp)
        let newLat = CLLocationDegrees(resultLat * (180.0 / .pi))
        let newLon = CLLocationDegrees(resultLon * (180.0 / .pi))
        let result = CLLocation(latitude: newLat, longitude: newLon)
        return result
    }
    func nearByPoint(newPoint:CLLocation, array:[CLLocation],isMin:Bool)->Int{
        var distance = [Double]()
        for coord in array{
            distance.append(newPoint.distance(from: coord))
        }
        return (distance.index(of: isMin ? distance.min()!:distance.max()!)!)
    }

}
class UserLocationManager: NSObject,CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!
    
    override init() {
        super.init()
        self.performSelector(onMainThread: #selector(initLocationManager), with: nil, waitUntilDone: true)
    }
    
    @objc private func initLocationManager() {
        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self
    }
    
    @objc private func deinitLocationManager() {
        locationManager = nil
    }
    
    deinit {
        self.performSelector(onMainThread: #selector(deinitLocationManager), with: nil, waitUntilDone: true)
    }
    
}
