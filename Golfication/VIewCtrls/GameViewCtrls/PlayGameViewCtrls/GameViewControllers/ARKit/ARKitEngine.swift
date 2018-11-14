//
//  ARKitEngine.swift
//  Golfication
//
//  Created by Rishabh Sood on 20/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
//https://objectivec2swift.com/#/converter/code/
//http://qaru.site/questions/1227258/remove-zoom-slider-in-uiimagepickercontroller

import ARKit
import CoreMotion
import Foundation
import SceneKit

struct ARKitOrientationSupport {
    var xOffset: CGFloat!
    var rotationAngle: CGFloat!
    var orientation: UIInterfaceOrientation!
    var viewSize: CGSize!
}

enum ARKitLookingType : Int {
    case kFrontLookingType
    case kFloorLookingType
}

var VIEWPORT_WIDTH_RADIANS: CGFloat = 0.5
var VIEWPORT_HEIGHT_RADIANS: CGFloat = 0.7392
var VIEWPORT_EXTRA_WIDTH_MARGIN: CGFloat = CGFloat(10 * Double.pi / 360) // 10 degrees margin
var ACCELEROMETER_UPDATE_FREQUENCY: CGFloat = 20 // Hz

public class ARKitEngine: NSObject, UIAccelerometerDelegate {

    var settingUnit: Int = 0
    var locArr = [CGPoint]()
    private var ar_coordinates: NSMutableArray!

    private var ar_coordinateViews: [ARObjectView]!
    private var ar_floorCoordinateViews: [ARObjectView]!
    
    private var delegate: ARViewDelegate!
    private var cameraController: UIImagePickerController!
    private var radar: RadarView!
    private var ar_overlayView: UIView!
    private var ar_debugView: UILabel!
    private var updateTimer: Timer!
    private var maximumScaleDistance: Double = 0.0
    private var showsFloorImages = false
    private var scaleViewsBasedOnDistance = false
    private var minimumScaleFactor: CGFloat = 0.0
    private var rotateViewsBasedOnPerspective = false
    private var maximumRotationAngle: CGFloat = 0.0
    private var updateFrequency: CGFloat = 0.0
    private var debugMode = false
    private var useAltitude = false
    private var lookingType: ARKitLookingType!
    private var centerCoordinate: ARGeoCoordinate!
    private var motionManager: CMMotionManager!
    private var baseViewController: UIViewController!
    
    private var orientationSupporter: ARKitOrientationSupport!
    private var loadingView: UIView!
    private var lineNode: SCNNode!
    
    var sceneView: ARSCNView!

    init(config conf: ARKitConfig) {
    super.init()
        
        //if let config = conf{
            ar_coordinates = NSMutableArray()

            ar_coordinateViews = [ARObjectView]()
            ar_floorCoordinateViews = [ARObjectView]()
            
            showsFloorImages = conf.showsFloorImages
            scaleViewsBasedOnDistance = conf.scaleViewsBasedOnDistance
            minimumScaleFactor = conf.minimumScaleFactor
            assert(minimumScaleFactor >= 0.0 && minimumScaleFactor <= 1.0, "Minimum Scale Factor must be between 0.0 and 1.0!!")
            if minimumScaleFactor == 1.0 {
                debugPrint("WARNING!!! Minimum Scale Factor will make AR points size 0")
            }
            rotateViewsBasedOnPerspective = conf.rotateViewsBasedOnPerspective
            maximumRotationAngle = conf.maximumRotationAngle
            updateFrequency = conf.updateFrequency
            debugMode = conf.debugMode
            delegate = conf.delegate
            assert(delegate != nil, "Nil Delegate provided, cannot start")
            
            loadingView = conf.loadingView
            useAltitude = conf.useAltitude
            
            orientationSupporter = ARKitOrientationSupport(xOffset: 0.0, rotationAngle: 0.0, orientation: UIInterfaceOrientation.portrait, viewSize: UIScreen.main.bounds.size)
            switch conf.orientation {
            case .portrait:
                orientationSupporter.orientation = UIInterfaceOrientation.portrait
                orientationSupporter.xOffset = 0.0
                orientationSupporter.rotationAngle = 0.0
                orientationSupporter.viewSize = UIScreen.main.bounds.size
                
            case .landscapeLeft:
                orientationSupporter.orientation = UIInterfaceOrientation.landscapeLeft
                orientationSupporter.xOffset = -80.0
                orientationSupporter.rotationAngle = CGFloat(-Double.pi / 2)
                let s: CGSize = UIScreen.main.bounds.size
                orientationSupporter.viewSize = CGSize(width: s.height, height: s.width)
                
            case .landscapeRight:
                orientationSupporter.orientation = UIInterfaceOrientation.landscapeRight
                orientationSupporter.xOffset = -80.0
                orientationSupporter.rotationAngle = CGFloat(Double.pi / 2)
                let s: CGSize = UIScreen.main.bounds.size
                orientationSupporter.viewSize = CGSize(width: s.height, height: s.width)
            case .portraitUpsideDown:
                orientationSupporter.orientation = UIInterfaceOrientation.portraitUpsideDown
                orientationSupporter.xOffset = 0.0
                orientationSupporter.rotationAngle = CGFloat(Double.pi)
                orientationSupporter.viewSize = UIScreen.main.bounds.size
            default:
                break
            }
            
            cameraController = UIImagePickerController()
            cameraController?.sourceType = .camera
            
            let screenSize: CGSize = UIScreen.main.bounds.size
            
            let cameraAspectRatio: Float = 4.0 / 3.0
            let imageWidth: Float = floorf(Float(screenSize.width * CGFloat(cameraAspectRatio)))
            let scale: Float = ceilf(Float((screenSize.height / CGFloat(imageWidth)) * 10.0)) / 10.0
            cameraController.cameraViewTransform = CGAffineTransform(a: CGFloat(scale), b: 0, c: 0, d: CGFloat(scale), tx: 0, ty: 80.0)
            
            cameraController.showsCameraControls = false
            cameraController.isNavigationBarHidden = true
            //cameraController.view.isUserInteractionEnabled = false
            
            radar = RadarView.init(at: (conf.radarPoint))
            radar.points = ar_coordinates
            
            ar_overlayView = UIView(frame: CGRect.zero)
            ar_overlayView.transform = CGAffineTransform(rotationAngle: orientationSupporter.rotationAngle)
            ar_overlayView.frame = UIScreen.main.bounds
            ar_overlayView.clipsToBounds = true
            addExtraView(radar)
            
            cameraController.cameraOverlayView = ar_overlayView
            
            if debugMode {
                ar_debugView = UILabel(frame: CGRect.zero)
                ar_debugView.backgroundColor = UIColor.white
                ar_debugView.textAlignment = .center
                ar_debugView.text = "Waiting..."
                
                ar_overlayView.addSubview(ar_debugView)
            }
        //}
    }
    
    func addExtraView(_ extra: UIView) {
        ar_overlayView.addSubview(extra)
        ar_overlayView.bringSubview(toFront: extra)
        extra.layer.zPosition = 1000
    }
    
    // MARK: - Coordinates storage management
    func add(_ coordinate: ARGeoCoordinate) {
            ar_coordinates.add(coordinate)
            
            if coordinate.radialDistance > maximumScaleDistance {
                maximumScaleDistance = coordinate.radialDistance
            }
            
            //message the delegate.
            let ob: ARObjectView = (delegate?.view(for: coordinate, floorLooking: false))!
            ob.controller = self
            ar_coordinateViews.append(ob)
            
            if showsFloorImages {
                let floor: ARObjectView = (delegate?.view(for: coordinate, floorLooking: true))!
                floor.controller = self
                ar_floorCoordinateViews.append(floor)
            }
            
            coordinate.calibrate(usingOrigin: centerCoordinate?.geoLocation, useAltitude: useAltitude)
            if coordinate.radialDistance > maximumScaleDistance {
                maximumScaleDistance = coordinate.radialDistance
                radar?.farthest = maximumScaleDistance
            }
    }
    
    func addCoordinates(_ newCoordinates: NSArray) {
        if numberOfCurve>1{
        let tempArray = NSMutableArray()
        for i in 1..<numberOfCurve+1{
            tempArray.add(newCoordinates[newCoordinates.count-i])
        }
        radar.points = tempArray
        }
        for coordinate in newCoordinates {
            add(coordinate as! ARGeoCoordinate)
        }
    }
    
    func remove(_ coordinate: ARGeoCoordinate) {
        let indexToRemove: Int = ar_coordinates.index(of: coordinate)
        if indexToRemove != NSNotFound {
            ar_coordinates.removeObject(at: indexToRemove)
            let frontView: UIView? = ar_coordinateViews?[indexToRemove]
            let floorView: UIView? = ar_floorCoordinateViews?[indexToRemove ]
            frontView?.removeFromSuperview()
            floorView?.removeFromSuperview()
            ar_coordinateViews.remove(at: indexToRemove)
            ar_floorCoordinateViews.remove(at: indexToRemove)
        }
    }
    
    func removeCoordinates(_ coordinates: NSArray) {
        for coordinateToRemove: ARGeoCoordinate? in coordinates as? [ARGeoCoordinate?] ?? [] {
            remove(coordinateToRemove!)
        }
    }
    
    func removeAllCoordinates() {
        ar_coordinates.removeAllObjects()
        for v: UIView? in (ar_coordinateViews)! {
            v?.removeFromSuperview()
        }
        for v: UIView? in (ar_floorCoordinateViews)! {
            v?.removeFromSuperview()
        }
        ar_coordinateViews.removeAll()
        ar_floorCoordinateViews.removeAll()
    }

    /*func LocationSortClosestFirst(s1: ARGeoCoordinate?, s2: ARGeoCoordinate?, ignore: UnsafeMutableRawPointer?) -> ComparisonResult {
        if s1?.radialDistance < s2?.radialDistance {
            return .orderedAscending
        } else if s1?.radialDistance > s2?.radialDistance {
            return .orderedDescending
        } else {
            return .orderedSame
        }
    }*/
    
    func startListening() {
        
        //start our heading readings and our accelerometer readings.
        LocalizationHelper.shared().register(forUpdates: self, once: false)
        
        motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = TimeInterval(1.0 / ACCELEROMETER_UPDATE_FREQUENCY)
        motionManager.gyroUpdateInterval = TimeInterval(1.0 / ACCELEROMETER_UPDATE_FREQUENCY)
        
        if let aQueue = OperationQueue.current {
            motionManager.startAccelerometerUpdates(to: aQueue, withHandler: { accelerometerData, error in
                var z0: CGFloat = 0.0
                
                let dt: TimeInterval = TimeInterval(1.0 / ACCELEROMETER_UPDATE_FREQUENCY)
                let RC: Double = 0.3
                let alpha: Double = dt / (RC + dt)
                
                let currZ: CGFloat = CGFloat((alpha * (accelerometerData?.acceleration.z ?? 0.0)) + (1.0 - alpha) * Double(z0))
                
                //update the center coordinate inclination.
                if self.centerCoordinate != nil{
                self.centerCoordinate.inclination = Double(currZ * VIEWPORT_HEIGHT_RADIANS)
                }
                z0 = currZ
            })
        }
        if (centerCoordinate != nil) {
            doStart()
        } else {

            if (loadingView == nil) {
                loadingView = UIView.init(frame: cameraController.view.bounds)
                loadingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
                let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
                spinner.startAnimating()
                loadingView.addSubview(spinner)
                spinner.center = loadingView.center
                let loadingText = UILabel(frame: CGRect.zero)
                loadingText.textAlignment = .center
                loadingText.text = NSLocalizedString("Locating", comment: "")
                loadingText.backgroundColor = UIColor.clear
                loadingText.textColor = UIColor.white
                loadingText.sizeToFit()
                loadingView.addSubview(loadingText)
                loadingText.center = CGPoint(x: spinner.center.x, y: spinner.center.y + spinner.frame.size.height * 2)

            }
            else{
                loadingView.frame = cameraController.view.bounds
            }
            loadingView.sizeToFit()
            UIApplication.shared.keyWindow?.addSubview(loadingView)
        }
    }
    
    func hide() {
        updateTimer.invalidate()
        updateTimer = nil
        LocalizationHelper.shared().deregister(forUpdates: self)
        baseViewController.dismiss(animated: false, completion: nil)
    }

    func dataObject(with index: Int) -> Any? {
        return (ar_coordinates[index] as? ARGeoCoordinate)?.dataObject
    }
    
    func frontView(with index: Int) -> ARObjectView? {
        return ar_coordinateViews[index]
    }
    
    func floorView(with index: Int) -> ARObjectView? {
        return ar_floorCoordinateViews[index]
    }
    
    // MARK: - ARObjectView controller method
    @objc  func viewTouched(_ view: ARObjectView) {
//        if lookingType == .kFrontLookingType {
        if let ind = ar_coordinateViews.index(of: view){
            delegate.itemTouched(with: ind)
        }else if let ind = ar_floorCoordinateViews.index(of: view){
            delegate.itemTouched(with: ind)
        }
    }
    var shapeView: CAShapeLayer!
    var numberOfCurve = 0
}

extension ARKitEngine {
    func resetView(_ theView: ARObjectView, value scaleValue: CGFloat) {
        if theView.superview != nil {
            var scaleFactor: CGFloat = 1.0
            theView.layer.transform = CATransform3DIdentity
            if scaleViewsBasedOnDistance && ar_coordinateViews.contains(theView) {
                scaleFactor = 1.0 - minimumScaleFactor * (scaleValue / CGFloat(maximumScaleDistance))
                theView.frame = CGRect(x: theView.frame.origin.x, y: theView.frame.origin.y, width: (theView.frame.size.width) / scaleFactor, height: (theView.frame.size.height) / scaleFactor)
                }
            theView.removeFromSuperview()
        }
    }
    
    func floorPositioning(_ theView: ARObjectView, at coord: ARGeoCoordinate) {
        if theView.displayed {
            let centerAzimuth = centerCoordinate.azimuth
            
            var coordAzimuth: Double = coord.azimuth - centerAzimuth
            if coordAzimuth < 0.0 {
                coordAzimuth = 2 * Double.pi + coordAzimuth
            }
            
            let offset: CGFloat = orientationSupporter.viewSize.height / 2
            
            theView.center = CGPoint(x: ar_overlayView.center.x - orientationSupporter.xOffset, y: offset)
            theView.transform = CGAffineTransform(rotationAngle: CGFloat(coordAzimuth))
            
            //if we don't have a superview, set it up.
            if (theView.superview) == nil {
                ar_overlayView.addSubview(theView)
                ar_overlayView.sendSubview(toBack: theView)
            }
        }
    }

    func frontPositioning(_ theView: ARObjectView, at coord: ARGeoCoordinate) {

        if theView.displayed && viewportContains(coord) {
            
            let loc: CGPoint = point(in: ar_overlayView, for: coord)
            locArr.append(loc)
            var scaleFactor: CGFloat = 1.0
            if scaleViewsBasedOnDistance {
                scaleFactor = 1.0 - minimumScaleFactor * CGFloat(coord.radialDistance / maximumScaleDistance)
            }
            
            var width: CGFloat = (theView.bounds.size.width)
            var height: CGFloat = (theView.bounds.size.height)
            
            if (theView.superview) == nil {
                width = theView.bounds.size.width * scaleFactor;
                height = theView.bounds.size.height * scaleFactor;
            }
            
            theView.frame = CGRect(x: loc.x - CGFloat(width) / 2.0, y: loc.y - CGFloat(height) / 2.0, width: CGFloat(width), height: CGFloat(height))

            if rotateViewsBasedOnPerspective {
                var transform: CATransform3D = CATransform3DIdentity
                
                transform.m34 = 1.0 / 300.0
                // TODO fix rotation angle
                var itemAzimuth: Double = coord.azimuth
                var centerAzimuth: Double = centerCoordinate.azimuth
                if itemAzimuth - centerAzimuth > Double.pi {
                    centerAzimuth += 2 * Double.pi
                }
                if itemAzimuth - centerAzimuth < -Double.pi {
                    itemAzimuth += 2 * Double.pi
                }
                
                let angleDifference: Double = itemAzimuth - centerAzimuth
                transform = CATransform3DRotate(transform, maximumRotationAngle * CGFloat(angleDifference) / (VIEWPORT_WIDTH_RADIANS / 2.0), 0, 1, 0)
                theView.layer.transform = transform
            }
            //if we don't have a superview, set it up.
            if (theView.superview) == nil {
                
                // ----------------------- My Code ---------------------------
                let text = coord.dataObject
                var distance = coord.baseDistance
                
                var suffix = "meter"
                if settingUnit != 1 {
                    distance = distance * 1.09361
                    suffix = "yard"
                }
                let finalDistance = Int(distance)
                for img in theView.subviews{
                    if img.isKind(of: UIImageView.self) {
                        for lbl in img.subviews {
                            if lbl.isKind(of: UILabel.self) {
                                (lbl as! UILabel).text = "\(text ?? "")\n\(finalDistance) \(suffix)"
                                //lbl.text = text
                            }
                        }
                    }
                }

                //------------------------- Curve Code --------------------------------
                if numberOfCurve>1{
                    let tempArray = NSMutableArray()
                    for i in 1..<numberOfCurve+1{
                        tempArray.add(ar_coordinates[ar_coordinates.count-i])
                    }
                    for i in 0..<tempArray.count-1{
                        let curvePoint1 = tempArray[i] as! ARGeoCoordinate
                        let curvePoint2 = tempArray[i+1] as! ARGeoCoordinate
 
                        let loc1: CGPoint = point(in: ar_overlayView, for: curvePoint1)
                        let loc2: CGPoint = point(in: ar_overlayView, for: curvePoint2)
                        self.createCurve(p1:loc1, p2: loc2)
                    }
                }
                // ----------------------------------------------------------------------
                if text as! String == ""{
                    theView.alpha = 0
                    theView.isHidden = true
                }
                ar_overlayView.addSubview(theView)
                ar_overlayView.sendSubview(toBack: theView)
            }
        }
        else {
            resetView(theView, value: CGFloat(coord.radialDistance))
            if numberOfCurve>1{
            if let layers = ar_overlayView.layer.sublayers{
                for shape in layers{
                    if shape.isKind(of: CAShapeLayer.self){
                        shape.removeFromSuperlayer()
                        shape.sublayers = nil
                    }
                }
            }
        }
        }
    }
    
    func createCurve(p1:CGPoint,p2:CGPoint){

        let path = UIBezierPath()
        let cp = CGPoint(x: (p1.x+p2.x)/2, y: ((p1.y+p2.y)/2)-100)
        path.move(to: p1)
        path.addQuadCurve(to: p2, controlPoint: cp)
        shapeView = CAShapeLayer()
        shapeView.path = path.cgPath
        shapeView.strokeColor = UIColor.cyan.cgColor
        shapeView.fillColor = UIColor.clear.cgColor
        shapeView.lineWidth = 5.0
        shapeView.lineCap = kCALineCapRound
        
        if p1 == p2{
            if let layers = ar_overlayView.layer.sublayers{
                for shape in layers{
                    if shape.isKind(of: CAShapeLayer.self){
                        shape.removeFromSuperlayer()
                        shape.sublayers = nil
                    }
                }
            }
        }
        ar_overlayView?.layer.addSublayer(shapeView)
    }
    
    /* Converts a CLLocation object to a matrix_float4x4
     with the 3rd column representing the location in SCNKit coordinates */
    func getARCoordinateOfBuilding(userLocation: CLLocation,
                                   buildingLocation: CLLocation, distanceFromUserInMiles: Double) -> matrix_float4x4 {
        let bearing = getBearingBetweenPoints(point1: userLocation, point2: buildingLocation)
        let originTransform = matrix_identity_float4x4
        
        // Create a transform with a translation of distance meters away
        //let milesPerMeter = 1609.344
//        let distanceInMeters = distanceFromUserInMiles * milesPerMeter
        let distanceInMeters = distanceFromUserInMiles

        // Matrix that will hold the position of the building in AR coordinates
        var translationMatrix = matrix_identity_float4x4
        translationMatrix.columns.3.z = -1 * Float(distanceInMeters)
        
        // Rotate the position matrix
        let rotationMatrix = MatrixHelper.rotateMatrixAroundY(degrees: Float(bearing * -1),
                                                              matrix: translationMatrix)
        
        // Multiply the rotation by the translation
        let transformMatrix = simd_mul(rotationMatrix, translationMatrix)
        
        // Multiply the origin by the translation to get the coordinates
        return simd_mul(originTransform, transformMatrix)
    }
    
    // Adapted from https://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
    func getBearingBetweenPoints(point1 : CLLocation, point2 : CLLocation) -> Double {
        let lat1 = degreesToRadians(point1.coordinate.latitude)
        let lon1 = degreesToRadians(point1.coordinate.longitude)
        
        let lat2 = degreesToRadians(point2.coordinate.latitude)
        let lon2 = degreesToRadians(point2.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansToDegrees(radiansBearing)
    }
    
    func point(in realityView: UIView, for coordinate: ARGeoCoordinate) -> CGPoint {
        
        var point = CGPoint()
        
        //x coordinate.
        
        var pointAzimuth: Double = coordinate.azimuth
        
        //our x numbers are left based.
        var leftEdgeAzimuth: Double = centerCoordinate.azimuth - Double(VIEWPORT_WIDTH_RADIANS) / 2.0
        
        if leftEdgeAzimuth < 0.0 {
            leftEdgeAzimuth = 2 * Double.pi + leftEdgeAzimuth
        }
        
        if leftEdgeAzimuth > (pointAzimuth) {
            pointAzimuth += 2 * Double.pi
        }
        
        point.x = (CGFloat((pointAzimuth) - leftEdgeAzimuth) / VIEWPORT_WIDTH_RADIANS) * orientationSupporter.viewSize.width

        //y coordinate.
        let topInclination: Double = centerCoordinate.inclination - Double(VIEWPORT_HEIGHT_RADIANS) / 2.0

        point.y = orientationSupporter.viewSize.height - (CGFloat(coordinate.inclination - topInclination) / VIEWPORT_HEIGHT_RADIANS) * orientationSupporter.viewSize.height
        
        return point
    }
    
    func viewportContains(_ coordinate: ARGeoCoordinate) -> Bool {
        let centerAzimuth = centerCoordinate.azimuth
        var leftEdgeAzimuth: Double = centerAzimuth - Double(VIEWPORT_WIDTH_RADIANS) / 2.0 - Double(VIEWPORT_EXTRA_WIDTH_MARGIN)
        
        if leftEdgeAzimuth < 0.0 {
            leftEdgeAzimuth = 2 * Double.pi + leftEdgeAzimuth
        }
        
        var rightEdgeAzimuth: Double = centerAzimuth + Double(VIEWPORT_WIDTH_RADIANS) / 2.0 + Double(VIEWPORT_EXTRA_WIDTH_MARGIN)
        
        if rightEdgeAzimuth > 2 * Double.pi {
            rightEdgeAzimuth = rightEdgeAzimuth - 2 * Double.pi
        }
        
        var result: Bool = coordinate.azimuth > leftEdgeAzimuth && coordinate.azimuth < rightEdgeAzimuth
        if leftEdgeAzimuth > rightEdgeAzimuth {
            result = coordinate.azimuth < rightEdgeAzimuth || coordinate.azimuth > leftEdgeAzimuth
        }
        
        let centerInclination = centerCoordinate.inclination
        let bottomInclination: Double = centerInclination - Double(VIEWPORT_HEIGHT_RADIANS) / 2.0
        let topInclination: Double = centerInclination + Double(VIEWPORT_HEIGHT_RADIANS) / 2.0
        
        //check the height.
        result = result && (coordinate.inclination > bottomInclination && coordinate.inclination < topInclination)
        
        return result
    }
}

extension ARKitEngine:LocalizationDelegate {

    public func locationFound(_ location: CLLocation) {
        
        if (location.horizontalAccuracy) < 0.0 || (location.verticalAccuracy) < 0.0 {
            debugPrint("Invalid location received")
        } else {
            var willStart: Bool
            
            if (centerCoordinate == nil) {
                // TODO only update if change is significant
                willStart = true
                centerCoordinate = ARGeoCoordinate(location: location)
            } else {
                willStart = false
                centerCoordinate.geoLocation = location
            }
            
            maximumScaleDistance = 0.0
            for geoLocation in ar_coordinates {
                (geoLocation as! ARGeoCoordinate).calibrate(usingOrigin: location, useAltitude: useAltitude)
                if (geoLocation as! ARGeoCoordinate).radialDistance > maximumScaleDistance {
                    maximumScaleDistance = (geoLocation as AnyObject).radialDistance
                }
            }
            radar.farthest = maximumScaleDistance
            
            if willStart {
                doStart()
            }
        }
    }
    func doStart() {
        loadingView.removeFromSuperview()
        
        // Find the top window (that is not an alert view or other window)
        let topWindow: UIWindow = UIApplication.shared.keyWindow!
        if topWindow.windowLevel != UIWindowLevelNormal {
            let windows = UIApplication.shared.windows
            for topWindow in windows {
                if topWindow.windowLevel == UIWindowLevelNormal {
                    break
                }
            }
        }
        
        let rootView: UIView = (topWindow.subviews[(topWindow.subviews.count) - 1])
        let nextResponder = rootView.next!
        
        if nextResponder.isKind(of: UIViewController.self) {
            baseViewController = nextResponder as? UIViewController
        } else {
            assert(false, "ARModule: Could not find a root view controller.")
        }
        
        baseViewController.present(cameraController, animated: false)
        
        if debugMode {
            ar_debugView.sizeToFit()
            ar_debugView.frame = CGRect(x: 0, y: orientationSupporter.viewSize.height - ar_debugView.frame.size.height, width: orientationSupporter.viewSize.width, height: ar_debugView.frame.size.height)
        }
        
        if (updateTimer == nil) {
            updateTimer = Timer.scheduledTimer(timeInterval: TimeInterval(updateFrequency), target: self, selector: #selector(self.updateLocations(_:)), userInfo: nil, repeats: true)
        }
    }
    
    @objc func updateLocations(_ timer: Timer) {
        radar.updatePoints(centerCoordinate)
        
        if (ar_coordinateViews == nil) || ar_coordinateViews.count == 0 {
            return
        }
        
        if debugMode{
        ar_debugView.text = centerCoordinate.description
        }
        var index: Int = 0
        let inclination = radiansToDegrees(centerCoordinate.inclination)
        let floorLooking: Bool = inclination < -70.0 && inclination > -130.0
        
        if floorLooking && showsFloorImages {
            if lookingType == .kFrontLookingType {
                lookingType = .kFloorLookingType
                delegate.didChangeLooking(floorLooking)
            }
        } else {
            if lookingType == .kFloorLookingType {
                lookingType = .kFrontLookingType
                delegate.didChangeLooking(floorLooking)
            }
        }
        
        var count: Int = 0
        for item in ar_coordinates {
            var viewToDraw: ARObjectView! = nil
            var otherView: ARObjectView! = nil
            if floorLooking && showsFloorImages {
                viewToDraw = ar_floorCoordinateViews[index]
                floorPositioning(viewToDraw, at: item as! ARGeoCoordinate)
                otherView = ar_coordinateViews[index]
                resetView(otherView, value: CGFloat((item as! ARGeoCoordinate).radialDistance))
            } else {
                if ar_floorCoordinateViews.count > 0 {
                    otherView = ar_floorCoordinateViews[index]
                    resetView(otherView, value: CGFloat((item as! ARGeoCoordinate).radialDistance))
                }
                viewToDraw = ar_coordinateViews[index]
                frontPositioning(viewToDraw, at: item as! ARGeoCoordinate)
                viewToDraw?.layer.zPosition = CGFloat(-60 * count)
                count += 1
            }
            index += 1
        }
    }
    
    public func headingFound(_ newHeading: CLHeading) {
        if (newHeading.headingAccuracy == -1.0) {
            debugPrint("Invalid heading");
        }
        else {
            let value: Double = newHeading.magneticHeading + radiansToDegrees(Double(CGFloat(orientationSupporter?.rotationAngle ?? 0.0)))
            centerCoordinate?.azimuth = fmod(value, 360.0) * (2 * (Double.pi / 360.0))
        }
    }

    public func locationUnavailable() {
        debugPrint("Location unavailable!")
    }
}
