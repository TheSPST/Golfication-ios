//
//  MapForInputViewController.swift
//  Golfication
//
//  Created by Khelfie on 23/08/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import MapKit
import FirebaseAuth

class MapForInputViewController: UIViewController,MKMapViewDelegate{
    @IBOutlet var mapView: MKMapView!
    @IBOutlet weak var btnZoom: UIButton!
    var arr = [NSMutableDictionary]()
    var newArr = [CLLocationCoordinate2D]()
    var savedPolyArr = [MKPolyline]()
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnStartStopScroll: UILocalizedButton!
    var polyLineArr = [MKPolyline]()
    var arrWithoutDict = [[Double]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        // setMapType
        mapView.mapType = .satellite
        self.mapView.delegate = self
        // set initial location in UserLocation
        let initialLocation = CLLocation(latitude: -33.977432, longitude: 151.131229)
        centerMapOnLocation(location: initialLocation)
        self.btnCancel.isHidden = true
        btnZoom.isHidden = true
        // Do any additional setup after loading the view.
    }
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius, regionRadius)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    @IBAction func btnCancelAction(_ sender: Any) {
        self.mapView.removeOverlays(polyLineArr)
        self.polyLineArr.removeAll()
        self.arr.removeAll()
        self.newArr.removeAll()
    }
    
    @IBAction func btnZoomAction(_ sender: UIButton) {
        if(btnZoom.currentTitle! == "ZoomIn"){
            btnZoom.setTitle("ZoomOut", for: .normal)
        }else{
            btnZoom.setTitle("ZoomIn", for: .normal)
        }
    }

    var counter = 0
    @IBAction func btnActionStartStopScrolling(_ sender: UIButton) {
        if(btnStartStopScroll.currentTitle! == "Start".localized()){
            self.btnCancel.isHidden = false
            arr.removeAll()
            newArr.removeAll()
            btnStartStopScroll.setTitle("Stop", for: .normal)
            mapView.isScrollEnabled = false
            counter = 0
        }else{
            mapView.isScrollEnabled = true
            self.btnCancel.isHidden = true
            self.mapView.removeOverlays(polyLineArr)
            uploadCoordinates()
            createPolyline()
        }
    }
    func uploadCoordinates(){
        if arr.count > 0{
            ref.child("userData/\(Auth.auth().currentUser!.uid)/inputLocation").updateChildValues(["\(Timestamp)":arrWithoutDict])
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func createPolyline(){
        // creating Coordiates array for polyline
        var location = [CLLocationCoordinate2D]()
        for latLng in self.arr{
            location.append(CLLocationCoordinate2D(latitude: latLng.value(forKey: "lat") as! Double, longitude: latLng.value(forKey: "lng") as! Double))
        }
        // Create a polyline
        let polyline1 = MKPolyline(coordinates: &location, count: location.count)
        savedPolyArr.append(polyline1)
        // add Polyline to map
        self.mapView.add(polyline1)
        btnStartStopScroll.setTitle("Start".localized(), for: .normal)
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline && self.btnStartStopScroll.currentTitle! == "Stop"{
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.glfBluegreen
            renderer.lineWidth = 3
            return renderer
        }
        return MKOverlayRenderer()
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Let's put in a log statement to see the order of events
        debugPrint("Start")
        for touch in touches {
            let touchPoint = touch.location(in: self.mapView)
            let location = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            debugPrint("\(location.latitude), \(location.longitude)")
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("Move")
        for touch in touches {
            let touchPoint = touch.location(in: self.mapView)
            let location = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            debugPrint("\(location.latitude), \(location.longitude)")
            let dict = NSMutableDictionary()
            dict.setValue(location.latitude, forKey: "lat")
            dict.setValue(location.longitude, forKey: "lng")
            var array = [Double]()
            array.append(location.longitude)
            array.append(location.latitude)
            if(self.counter%3 == 0){
                if(self.btnStartStopScroll.currentTitle! == "Stop"){
                    arr.append(dict)
                    newArr.append(location)
                    let polyline = MKPolyline(coordinates: &newArr, count: newArr.count)
                    self.arrWithoutDict.append(array)
                    mapView.add(polyline) //Add lines
                    polyLineArr.append(polyline)
                }
            }
            counter += 1
        }
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        debugPrint("End")
        for touch in touches {
            let touchPoint = touch.location(in: self.mapView)
            let location = self.mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
            debugPrint("\(location.latitude), \(location.longitude)")
            newArr.removeAll()
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
//private extension MKPolyline {
//    convenience init(coordinates coords: Array<CLLocationCoordinate2D>) {
//        var unsafeCoordinates = UnsafeMutablePointer<CLLocationCoordinate2D>.allocate(capacity: coords.count)
//        unsafeCoordinates.initialize(to: coords)
//        self.init(coordinates: unsafeCoordinates, count: coords.count)
//        unsafeCoordinates.deallocate()
//    }
//}
