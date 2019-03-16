//
//  IntentViewController.swift
//  IntentUI
//
//  Created by Peter Minarik on 03.07.18.
//  Copyright © 2018 Peter Minarik. All rights reserved.
//
//https://www.raywenderlich.com/600-sirikit-tutorial-for-ios

import IntentsUI
import CoreData
import MapKit
import CoreLocation
// As an example, this extension's Info.plist has been configured to handle interactions for INSendMessageIntent.
// You will want to replace this or add other intents as appropriate.
// The intents whose interactions you wish to handle must be declared in the extension's Info.plist.

// You can test this example integration by saying things to Siri like:
// "Send a message using <myApp>"

class IntentViewController: UIViewController, INUIHostedViewControlling {
    
    @IBOutlet weak var mapView: MKMapView!
    let context = CoreDataStorage.mainQueueContext()
    var counter : GreenDistanceEntity?
    var c : FrontBackDistanceEntity?
    //    var locationManager = CLLocationManager()
    let userLocation = UserLocationManager()
    let distanceUtil = DistanceUtil()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if(userLocation.locationManager.location == nil){
            userLocation.locationManager.requestAlwaysAuthorization()
            userLocation.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        if let currentLocation: CLLocation = userLocation.locationManager.location{
            self.mapView.mapType = MKMapType.satellite
            self.mapView.showsUserLocation = true
            self.context.performAndWait{ () -> Void in
                if let distanceUnitEntity = NSManagedObject.findAllForEntity("DistanceUnitEntity", context: self.context) as? [DistanceUnitEntity],!distanceUnitEntity.isEmpty{
                    distanceUtil.writeDistanceUnit(cDetails: distanceUnitEntity.last!)
                }
                if let currentHoleEntity = NSManagedObject.findAllForEntity("CurrentHoleEntity", context: self.context) as? [CurrentHoleEntity],!currentHoleEntity.isEmpty{
                    distanceUtil.writeHoleIndex(cDetails: currentHoleEntity.last!)
                    if let courseDetails = NSManagedObject.findAllForEntity("CourseDetailsEntity", context: self.context) as? [CourseDetailsEntity],!courseDetails.isEmpty{
                        distanceUtil.writeCourseDetails(cDetails: courseDetails.last!)
                    }
                    if let counterGreen = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: self.context) as? [GreenDistanceEntity],!counterGreen.isEmpty{
                        if let counterTee = NSManagedObject.findAllForEntity("TeeDistanceEntity", context: self.context) as? [TeeDistanceEntity],!counterTee.isEmpty{
                            let _ =  distanceUtil.getHoleNum(location: currentLocation, greeDisArr: counterGreen, teeArr: counterTee)
                            let locationValue = [["name":distanceUtil.userName!,"lat":"\(distanceUtil.currentLocation.coordinate.latitude)","log":"\(distanceUtil.currentLocation.coordinate.longitude)"],
                                                 ["name":"Flag\(Int(distanceUtil.distanceToCenter))","lat":"\(distanceUtil.flagPointOfGreen.coordinate.latitude)","log":"\(distanceUtil.flagPointOfGreen.coordinate.longitude)"]]
                            
                            mapView.delegate = self
                            mapView.register(LocationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
                            let locationsList = Location.locations(fromDictionaries: locationValue)
                            mapView.showAnnotations(locationsList, animated: true)
                            mapView.addAnnotations(locationsList)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - INUIHostedViewControlling
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        
        let width = self.extensionContext?.hostedViewMaximumAllowedSize.width ?? self.view.frame.size.width - 20
        let desiredSize = CGSize(width: width, height: 350)
        completion(true, parameters, desiredSize)
    }
}
extension IntentViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        let identifier = "CustomAnnotation"
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
            
            if !(annotationView!.annotation!.title!?.contains("Flag"))!{
//                annotationView!.image = UIImage(named: "nav")!
            }
            else{
                annotationView!.image = UIImage(named: "holeflag")!
            }
        }
        else {
            annotationView!.annotation = annotation
        }
        return annotationView
    }
}
