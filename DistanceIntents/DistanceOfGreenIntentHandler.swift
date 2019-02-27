//
//  PhotoOfTheDayIntentHandler.swift
//  SpacePhoto
//
//  Created by Peter Minarik on 03.07.18.
//  Copyright © 2018 Peter Minarik. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

class DistanceOfGreenIntentHandler: NSObject, DistanceOfGreenIntentHandling {
    let context = CoreDataStorage.mainQueueContext()
    var greenDistanceArray : GreenDistanceEntity?
    var locationManager = CLLocationManager()
    var frontBackDistanceArray : FrontBackDistanceEntity?
    var teeCoordinateArray : TeeDistanceEntity?
    func confirm(intent: DistanceOfGreenIntent, completion: @escaping (DistanceOfGreenIntentResponse) -> Void) {
        completion(DistanceOfGreenIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: DistanceOfGreenIntent, completion: @escaping (DistanceOfGreenIntentResponse) -> Void) {
        
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        if let currentLocation: CLLocation = self.locationManager.location{
            self.context.performAndWait{ () -> Void in
                if let counterGreen = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: self.context) as? [GreenDistanceEntity]{
                    if let counterTee = NSManagedObject.findAllForEntity("TeeDistanceEntity", context: self.context) as? [TeeDistanceEntity]{
                        let distanceInMeters = getHoleNum(location: currentLocation, greeDisArr: counterGreen, teeArr: counterTee)
                        completion(DistanceOfGreenIntentResponse.success(distanceString: distanceInMeters))
                        
                    }
                }
            }
        }
    }
    func getHoleNum(location:CLLocation,greeDisArr:[GreenDistanceEntity],teeArr:[TeeDistanceEntity])->String{
        
        //                    self.greenDistanceArray = (counter?.last as! GreenDistanceEntity)
        //                    let greenLocation = CLLocation(latitude:self.greenDistanceArray!.lat, longitude: self.greenDistanceArray!.lng)
        //                    let distanceInMeters = currentLocation.distance(from: greenLocation)
        var greenWiseData = [[CLLocation]]()
        var holeWiseData = [CLLocation]()
        
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
        var DistanceArr = [Double]()
        for i in 0..<holeWiseData.count{
            DistanceArr.append(holeWiseData[i].distance(from: location))
            DistanceArr.append(greenWiseData[i].first!.distance(from: location))
        }
        
        return "Distance to hole is 900.0 meter"
    }
}
