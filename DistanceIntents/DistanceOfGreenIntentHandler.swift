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
//    var locationManager = CLLocationManager()
    var frontBackDistanceArray : FrontBackDistanceEntity?
    var teeCoordinateArray : TeeDistanceEntity?
    let userLocation = UserLocationManager()
    let distanceUtil = DistanceUtil()
    func confirm(intent: DistanceOfGreenIntent, completion: @escaping (DistanceOfGreenIntentResponse) -> Void) {
        completion(DistanceOfGreenIntentResponse(code: .ready, userActivity: nil))
    }
    
    func handle(intent: DistanceOfGreenIntent, completion: @escaping (DistanceOfGreenIntentResponse) -> Void) {
        
        if(userLocation.locationManager.location == nil){
            userLocation.locationManager.requestAlwaysAuthorization()
            userLocation.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        
        if let currentLocation: CLLocation = userLocation.locationManager.location{
            self.context.performAndWait{ () -> Void in
                if let currentHoleEntity = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: self.context) as? [CurrentHoleEntity]{
                    distanceUtil.writeHoleIndex(cDetails: currentHoleEntity.last!)
                }
                if let courseDetails = NSManagedObject.findAllForEntity("CourseDetailsEntity", context: self.context) as? [CourseDetailsEntity]{
                    distanceUtil.writeCourseDetails(cDetails: courseDetails.last!)
                }
                if let counterTee = NSManagedObject.findAllForEntity("TeeDistanceEntity", context: self.context) as? [TeeDistanceEntity]{
                    if let counterGreen = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: self.context) as? [GreenDistanceEntity]{
                        let distanceInMeters = distanceUtil.getHoleNum(location: currentLocation, greeDisArr: counterGreen, teeArr: counterTee)
                        completion(DistanceOfGreenIntentResponse.success(distanceString: distanceInMeters))
                    }else if let frontBackEnt = NSManagedObject.findAllForEntity("FrontBackDistanceEntity", context: self.context) as? [FrontBackDistanceEntity]{
                        let distanceInMeters = distanceUtil.getHoleNumRF(location: currentLocation, rfHole: frontBackEnt, teeArr: counterTee)
                        completion(DistanceOfGreenIntentResponse.success(distanceString: distanceInMeters))
                    }
                }else{
                    completion(DistanceOfGreenIntentResponse.success(distanceString: "Please Start a game"))
                }
            }
        }else{
            debugPrint("Please enable your location")
            completion(DistanceOfGreenIntentResponse.success(distanceString: "Please enable your location"))

        }
    }
}
