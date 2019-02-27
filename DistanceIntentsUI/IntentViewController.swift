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
    
    @IBOutlet weak var labl: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    let context = CoreDataStorage.mainQueueContext()
    var counter : GreenDistanceEntity?
    var c : FrontBackDistanceEntity?
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(locationManager.location == nil){
            locationManager.requestAlwaysAuthorization()
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
        }
        
        if let currentLocation: CLLocation = self.locationManager.location{
            self.mapView.mapType = MKMapType.standard
            self.context.performAndWait{ () -> Void in
                let counter = NSManagedObject.findAllForEntity("GreenDistanceEntity", context: self.context)
                if (counter?.last != nil) {
                    self.counter = (counter?.last as! GreenDistanceEntity)
                    let location = CLLocationCoordinate2D(latitude: (self.counter?.lat)!,longitude: (self.counter?.lng)!)
                    let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    let region = MKCoordinateRegion(center: location, span: span)
                    self.mapView.setRegion(region, animated: true)
                    
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = location
                    annotation.title = "Qutub Golf Course"
                    //annotation.subtitle = "Qutub"
                    self.mapView.addAnnotation(annotation)
                    
                    //self.mapView.showsUserLocation = true
                    //let currentLocation = self.mapView.userLocation.location
                    let distanceInMeters = currentLocation.distance(from: CLLocation(latitude: location.latitude, longitude: location.longitude))
                    labl.text = "Distance To Hole : \(Int(distanceInMeters)) Meter"
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
