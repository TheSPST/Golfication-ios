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
            self.context.performAndWait{ () -> Void in
                if let counterGreen = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: self.context) as? [GreenDistanceEntity]{
                    if let counterTee = NSManagedObject.findAllForEntity("TeeDistanceEntity", context: self.context) as? [TeeDistanceEntity]{
                        let distanceInMeters =  distanceUtil.getHoleNum(location: currentLocation, greeDisArr: counterGreen, teeArr: counterTee)
                        
                        //let location = CLLocationCoordinate2D(latitude: distanceUtil.flagPointOfGreen.coordinate.latitude,longitude: distanceUtil.flagPointOfGreen.coordinate.longitude)
                        //let span = MKCoordinateSpan(latitudeDelta: 0, longitudeDelta: 0)
                        //let region = MKCoordinateRegion(center: location, span: span)
                        //self.mapView.setRegion(region, animated: true)
                        
                        /*let annotationUser = MKPointAnnotation()
                         annotationUser.coordinate = CLLocationCoordinate2D(latitude: distanceUtil.currentLocation.coordinate.latitude,longitude: distanceUtil.currentLocation.coordinate.longitude)
                         annotationUser.title = "User"
                         
                         let annotationFlag = MKPointAnnotation()
                         annotationFlag.coordinate = CLLocationCoordinate2D(latitude: distanceUtil.flagPointOfGreen.coordinate.latitude,longitude: distanceUtil.flagPointOfGreen.coordinate.longitude)
                         annotationFlag.title = "Flag\(Int(distanceUtil.distanceToCenter))"
                         
                         let annotationFront = MKPointAnnotation()
                         annotationFront.coordinate = CLLocationCoordinate2D(latitude: distanceUtil.nearbuyPointOfGreen.coordinate.latitude,longitude: distanceUtil.nearbuyPointOfGreen.coordinate.longitude)
                         annotationFront.title = "Front\(Int(distanceUtil.distanceToFront))"
                         
                         let annotationBack = MKPointAnnotation()
                         annotationBack.coordinate = CLLocationCoordinate2D(latitude: distanceUtil.endPointOfGreen.coordinate.latitude,longitude: distanceUtil.endPointOfGreen.coordinate.longitude)
                         annotationBack.title = "Back\(Int(distanceUtil.distanceToBack))"
                         
                         let viewRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 28.526066, longitude: 77.200176), latitudinalMeters: 1000, longitudinalMeters: 1000)
                         let adjustedRegion = self.mapView.regionThatFits(viewRegion)
                         self.mapView.setRegion(adjustedRegion, animated: true)
                         self.mapView.removeAnnotations(self.mapView.annotations)
                         
                         self.mapView.addAnnotation(annotationUser)
                         self.mapView.addAnnotation(annotationBack)
                         self.mapView.addAnnotation(annotationFront)
                         self.mapView.addAnnotation(annotationFlag)*/
                        
                        // ----------------------------------------------------------------
                        
                        let locationValue = [["name":"User","lat":"\(distanceUtil.currentLocation.coordinate.latitude)","log":"\(distanceUtil.currentLocation.coordinate.longitude)"],
                                             ["name":"Flag\(Int(distanceUtil.distanceToCenter))","lat":"\(distanceUtil.flagPointOfGreen.coordinate.latitude)","log":"\(distanceUtil.flagPointOfGreen.coordinate.longitude)"]
                            //,
//                                             ["name":"Front\(Int(distanceUtil.distanceToFront))","lat":"\(distanceUtil.nearbuyPointOfGreen.coordinate.latitude)","log":"\(distanceUtil.nearbuyPointOfGreen.coordinate.longitude)"],
                                             //["name":"Back\(Int(distanceUtil.distanceToBack))","lat":"\(distanceUtil.endPointOfGreen.coordinate.latitude)","log":"\(distanceUtil.endPointOfGreen.coordinate.longitude)"]
                                              ]
                        
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
    
    // MARK: - INUIHostedViewControlling
    // Prepare your view controller for the interaction to handle.
    func configureView(for parameters: Set<INParameter>, of interaction: INInteraction, interactiveBehavior: INUIInteractiveBehavior, context: INUIHostedViewContext, completion: @escaping (Bool, Set<INParameter>, CGSize) -> Void) {
        
        let width = self.extensionContext?.hostedViewMaximumAllowedSize.width ?? self.view.frame.size.width - 20
        let desiredSize = CGSize(width: width, height: 350)
        completion(true, parameters, desiredSize)
    }
}

extension IntentViewController: MKMapViewDelegate {
    
}

