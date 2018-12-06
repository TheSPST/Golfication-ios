//
//  ARPlanViewController.swift
//  Golfication
//
//  Created by Khelfie on 09/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//
import UIKit
import ARKit
import SceneKit
import GoogleMaps
import CoreLocation
struct CollisionTypes : OptionSet {
    let rawValue: Int
    static let bottom  = CollisionTypes(rawValue: 1 << 0)
    static let shape = CollisionTypes(rawValue: 1 << 1)
}

@available(iOS 11.0, *)
class ARPlanViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var heading = Double()
    var places = [Place]()
    var planes: [String : SCNNode] = [:]
    var bottomNode = SCNNode()
    var middlePoint : CLLocationCoordinate2D!
    var positionsOfCurveLines = [CLLocationCoordinate2D]()
    var positionOfCurvedPoint = [SCNVector3]()
    var positionOfCenterPointOfCurve = [SCNVector3]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = .gravity
            self.sceneView.session.run(configuration)
        }
    }
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showHelperAlertIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        self.configureLighting()
        self.sceneView.antialiasingMode = .multisampling4X
//        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
//        self.sceneView.debugOptions = .showWorldOrigin
    }
    
    private func configureWorldBottom() {
        let bottomPlane = SCNBox(width: 1000, height: 0.005, length: 1000, chamferRadius: 0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.clear
        bottomPlane.materials = [material]
        
        self.bottomNode = SCNNode(geometry: bottomPlane)
        bottomNode.position = SCNVector3(x: 0, y: -3, z: 0)
        let physicsBody = SCNPhysicsBody.static()
        physicsBody.categoryBitMask = CollisionTypes.bottom.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.shape.rawValue
        bottomNode.physicsBody = physicsBody
        self.sceneView.scene.rootNode.addChildNode(bottomNode)
        self.sceneView.scene.physicsWorld.contactDelegate = self
//        self.createShot()
        self.createMiddleArc()
        //        self.calculateOtherCoordinates()
    }

    func createMiddleArc(){
        let distance = GMSGeometryDistance(currentLocation, middlePoint)
        let head = GMSGeometryHeading(currentLocation, middlePoint)
        let point1 = touchedPoint
        let point2 = transform(rotationY: head, distance: distance,y:touchedPoint.y)
        let height = (distance*0.40)
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addQuadCurve(to: CGPoint(x:distance,y:0), controlPoint: CGPoint(x:distance*0.6,y:height))
        path.addLine(to: CGPoint(x:distance-0.5,y:0))
        path.addQuadCurve(to: CGPoint(x:0.5,y:0), controlPoint: CGPoint(x:distance*0.6,y:height-1))
        path.close()
        let shape = SCNShape(path: path, extrusionDepth: 0.4)
        shape.chamferRadius = 0.3
        shape.firstMaterial?.diffuse.contents = SKColor.cyan
        let scnNode = SCNNode(geometry: shape)
        scnNode.position = point1
        scnNode.rotation = SCNVector4(point2.x, point2.y, point2.z, 0.0)
        scnNode.geometry?.firstMaterial?.isDoubleSided = true
        self.bottomNode.addChildNode(scnNode)
    }
    func createShot(){
        let point1 = SCNVector3(x:0,y:0,z:0)
        let point2 = SCNVector3(x:0,y:0,z:30)
        let path = UIBezierPath()
        path.move(to: .zero)
        path.addQuadCurve(to: CGPoint(x:30,y:0), controlPoint: CGPoint(x:2,y:10))
        path.addLine(to: CGPoint(x:29,y:0))
        path.addQuadCurve(to: CGPoint(x:1,y:0), controlPoint: CGPoint(x:2,y:8))
        path.close()
        let shape = SCNShape(path: path, extrusionDepth: 0.25)
        shape.chamferRadius = 0.5
        shape.firstMaterial?.diffuse.contents = SKColor.cyan
        let scnNode = SCNNode(geometry: shape)
        scnNode.position = point1
        scnNode.rotation = SCNVector4(point2.x, point2.y, point2.z, 0.0)
        scnNode.geometry?.firstMaterial?.isDoubleSided = true
        self.bottomNode.addChildNode(scnNode)
        //        let totalPointsInBetween = self.getMultiplePoint(starting: point1, ending: point2)
        //            for data in totalPointsInBetween{
        //                let sphere = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0.1)
        //                sphere.firstMaterial?.diffuse.contents = SKColor.cyan
        //                let scnNode = SCNNode(geometry: sphere)
        //                scnNode.position = data
        ////                let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        ////                let repAction = SCNAction.repeatForever(action)
        ////                scnNode.runAction(repAction, forKey: "myrotate")
        //                self.bottomNode.addChildNode(scnNode)
        //        }
    }
    var nodeDetails = [(name:String,vector:SCNVector3)]()
    var viewFeatures = [UIImageView]()
    var nodeFeatures = [SCNNode]()
    func addMoreScenes(text:String,head:Double,distance:Double){
        let view = getViewForFeature(text: text, distance: distance)
        let planeGeoMetry = SCNSphere(radius: 10)
//        let bazier = UIBezierPath(roundedRect: view.frame, cornerRadius: view.frame.height/2)
//        let planeGeoMetry = SCNShape(path: bazier, extrusionDepth: 0.5)
//        let planeGeoMetry:SCNPlane = SCNPlane(width: view.bounds.width/2, height: view.bounds.height/2)
        planeGeoMetry.firstMaterial?.diffuse.contents = view
        
//        let textScene = SCNText(string: "\(text) \(Int(distance))", extrusionDepth: 1)
//        textScene.alignmentMode = kCAAlignmentCenter
        let textNode = SCNNode()
        textNode.geometry = planeGeoMetry
        textNode.position = transform(rotationY: head, distance: distance)
        debugPrint("Text Node \(text) Heading : \(head) Distance: \(distance) , Position  :\(textNode.position)")
        let action = SCNAction.rotateBy(x: 0, y: CGFloat(2 * Double.pi), z: 0, duration: 10)
        let repAction = SCNAction.repeatForever(action)
        textNode.runAction(repAction, forKey: "myrotate")
        self.bottomNode.addChildNode(textNode)
        nodeDetails.append((name:text,vector:textNode.position))
        nodeFeatures.append(textNode)
    }
    func getViewForFeature(text:String,distance:Double)-> UIView{
        let boxView = UIImageView.init(image: UIImage(named: "open_markerAR"))
        boxView.frame = CGRect(x: 0, y: 0, width: 150, height: 80)
        let imgViewInner = UIImageView()
        debugPrint(text)
        if text.contains("Bunker"){
            imgViewInner.image = UIImage(named: "bunkerAR")
        }else if text.contains("Hazard"){ 
            imgViewInner.image = UIImage(named: "hazardAR")
        }else if text.contains("Green"){
            imgViewInner.image = UIImage(named: "greenAR")
        }else if text.contains("Position"){
            imgViewInner.image = UIImage(named: "user_targetAR")
        }else if text.contains("Tee"){
            imgViewInner.image = UIImage(named: "teeAR")
        }
        imgViewInner.frame = CGRect(x: 15, y: 10, width: 35, height: 35)
        boxView.addSubview(imgViewInner)
        let lbl = UILabel.init(frame: CGRect(x:55, y:15, width:75, height:35))
        lbl.font = UIFont.systemFont(ofSize: 13.0)
        lbl.minimumScaleFactor = 2.0
        lbl.backgroundColor = UIColor.clear
        lbl.textColor = UIColor.white
        lbl.textAlignment = .left
        lbl.numberOfLines = 0
        lbl.text = "\(text) \(Int(distance*Constants.YARD)) yard"
        boxView.addSubview(lbl)
//        boxView.sizeToFit()
        self.viewFeatures.append(boxView)
        return boxView
    }
    func transform(rotationY: Double, distance: Double,y:Float = 0) -> SCNVector3 {
        let x = Float(distance*sin(degreesToRadians(rotationY)))
        let z = Float(distance*cos(degreesToRadians(rotationY)))
        let transform = SCNVector3(x:x,y:y,z:-z)
        return transform
    }
    
    var distanceHeading = [(head:Double,dist:Double)]()
    func calculateOtherCoordinates(){
        debugPrint(places)
        let teePosition = currentLocation
//            places[0].location!.coordinate
        nodeDetails.removeAll()
        for data in places{
            if let location = data.location{
                debugPrint(location.coordinate)
                let distance = GMSGeometryDistance(teePosition, location.coordinate)
                let head = GMSGeometryHeading(teePosition, location.coordinate)
                distanceHeading.append((head: head, dist: distance))
                addMoreScenes(text: data.placeName,head:head,distance:distance)
            }
        }
        for data in self.positionsOfCurveLines{
            let distance = GMSGeometryDistance(teePosition, data)
            let head = GMSGeometryHeading(teePosition, data)
            let offset = GMSGeometryOffset(teePosition, distance/2, head)
            self.positionOfCurvedPoint.append(transform(rotationY: head, distance: distance))
            self.positionOfCenterPointOfCurve.append(transform(rotationY: GMSGeometryHeading(teePosition, offset), distance: distance/2))
        }

        for i in 0..<self.positionOfCurvedPoint.count-1{
            let starting = self.positionOfCurvedPoint[i]
            let ending = self.positionOfCurvedPoint[i+1]
            let distance = distanceBetweenPoints2(A: starting, B: ending)
            var midP = positionOfCenterPointOfCurve[i]
            midP.y = Float(distance*0.3)
            let p1 = self.sceneView.projectPoint(starting)
            let p2 = self.sceneView.projectPoint(ending)
            let cp = CGPoint(x:Double((p1.x+p2.x)/2),y:Double((p1.y+p2.y)/2))
            let path = UIBezierPath()
            path.move(to: CGPoint(x: Double(p1.x), y: Double(p1.y)))
            path.addQuadCurve(to: CGPoint(x: Double(p2.x), y: Double(p2.y)), controlPoint: cp)
            path.addLine(to: CGPoint(x: Double(p2.x)-1, y: Double(p2.y)))
            path.addQuadCurve(to: CGPoint(x: Double(p1.x)+1, y: Double(p1.y)), controlPoint: CGPoint(x: cp.x - 1, y: cp.y - 1))
            path.close()
            let shape = SCNShape(path: path, extrusionDepth: 0.5)
            shape.firstMaterial?.diffuse.contents = SKColor.cyan

            let scnNode = SCNNode(geometry: shape)
            scnNode.position = positionOfCenterPointOfCurve[i]
            self.bottomNode.addChildNode(scnNode)
//            debugPrint(starting)
//            debugPrint(positionOfCenterPointOfCurve[i])
//            debugPrint(ending)
//            let totalPointsInBetween = self.getMultiplePoint(starting: starting, ending: ending)
//            for data in totalPointsInBetween{
//                let sphere = SCNBox(width: 0.5, height: 0.5, length: 1, chamferRadius: 0.5)
//                sphere.firstMaterial?.diffuse.contents = SKColor.cyan
//                let scnNode = SCNNode(geometry: sphere)
//                scnNode.position = data
//                self.bottomNode.addChildNode(scnNode)
//            }
        }
        /*
        let totalPointsInBetween = self.getMultiplePoint(starting: SCNVector3Make(0, 0, 0), ending:self.nodeDetails[0].vector)
        for data in totalPointsInBetween{
            let sphere = SCNBox(width: 1, height: 0.5, length: 1, chamferRadius: 0.1)
            sphere.firstMaterial?.diffuse.contents = SKColor.cyan
            let scnNode = SCNNode(geometry: sphere)
            scnNode.position = data
            self.bottomNode.addChildNode(scnNode)
        }
         */
//            let path = UIBezierPath()
//            path.move(to: .zero)
//            path.addQuadCurve(to: CGPoint(x: 100, y: 0), controlPoint: CGPoint(x: 25, y: distance*0.3))
//            path.addLine(to: CGPoint(x: 99, y: 0))
//            path.addQuadCurve(to: CGPoint(x: 1, y: 0), controlPoint: CGPoint(x: 25, y: (distance*0.3)-2))
//            path.close()
//            let path  = createBazierPath(starting: self.sceneView.projectPoint(starting), ending: self.sceneView.projectPoint(ending))
//            let shape = SCNShape(path: path, extrusionDepth: 0.75)
//            shape.firstMaterial?.diffuse.contents = SKColor.cyan
//            let curveNode = SCNNode(geometry: shape)
//            //https://stackoverflow.com/questions/28190604/scnshape-with-bezier-path
//            curveNode.position = positionOfCenterPointOfCurve[i]
//            curveNode.rotation = SCNVector4(x: starting.x, y: starting.y, z: starting.z, w: 0.0)
//            self.bottomNode.addChildNode(curveNode)

//            let geometry = SCNTorus(ringRadius: CGFloat(distance/2), pipeRadius: 0.5)
//            geometry.materials.first?.diffuse.contents = UIColor.blue
//            let ring = SCNNode(geometry: geometry)
//            ring.position = positionOfCenterPointOfCurve[i]
//            self.bottomNode.addChildNode(ring)
////            ring.rotation = SCNVector4Make(0, 1, 0, 90)
//            ring.rotation = SCNVector4Make(1, 0, 0, 90)
//        }
//        let starting = SCNVector3()
//        var ending = SCNVector3()
//        for data in nodeDetails{
//            if data.name.contains("Bunker"){
//                ending = data.vector
//                break
//            }
//        }
//        let distance = distanceBetweenPoints2(A: starting, B: ending)
//        let geometry = SCNTorus(ringRadius: CGFloat(distance/2), pipeRadius: 0.5)
//        geometry.materials.first?.diffuse.contents = UIColor.blue
//        let ring = SCNNode(geometry: geometry)
//        self.bottomNode.addChildNode(ring)
//        ring.rotation = SCNVector4Make(0, 1, 0, 90)
//        ring.rotation = SCNVector4Make(1, 0, 0, 90)
        
//        ring.runAction(SCNAction.rotate(by: 90, around: SCNVector3(x:0,y:0,z:0), duration: 0.0))
//        let mate = SCNMaterial()
//        mate.diffuse.contents = UIColor.red
//        let curvedLine = LineNode(v1: starting, v2: ending, material: [mate])
//        self.bottomNode.addChildNode(curvedLine)
//        self.createLine(startPosition: starting, endPosition: ending)
    }
    
    func getMultiplePoint(starting:SCNVector3,ending:SCNVector3)->[SCNVector3]{
        var totalPointsInBetween = self.Bresenham3D(starting: starting, ending: ending)
        debugPrint("Points :",totalPointsInBetween.count)
        let distance = distanceBetweenPoints2(A: starting, B: ending)
        let height : Float = Float(distance * 0.3)
        let yIncres : Float = Float((distance * 0.3)/(distance/2))
        
        for i in 0..<totalPointsInBetween.count{
            if i < totalPointsInBetween.count/2{
                totalPointsInBetween[i].y = Float(i)*yIncres
            }else{
                totalPointsInBetween[i].y = height + Float(((totalPointsInBetween.count/2)-i))*yIncres
            }
        }
        totalPointsInBetween.append(ending)
        return totalPointsInBetween
    }
//    func createBazierPath(starting:SCNVector3,ending:SCNVector3)->UIBezierPath{
//        let star = self.sceneView.projectPoint(starting)
//        let end = self.sceneView.projectPoint(ending)
//        let distance = distanceBetweenPoints2(A: starting, B: ending)
///*        let height = distance*0.3
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x:CGFloat(starting.x),y:CGFloat(starting.y)))
//        path.addQuadCurve(to:CGPoint(x:CGFloat(ending.x),y:CGFloat(ending.y)),controlPoint: CGPoint(x: CGFloat(starting.x) + distance/2, y: CGFloat(height)))
//        path.addLine(to: CGPoint(x:CGFloat(starting.x - 1),y:CGFloat(starting.y)))
//        path.addQuadCurve(to:CGPoint(x:CGFloat(starting.x),y:CGFloat(starting.y)),controlPoint: CGPoint(x: CGFloat(starting.x) + distance/2, y: CGFloat(height)))
//
//        path.close()*/
//        let path = UIBezierPath()
//        path.move(to: CGPoint(x: 0, y: 100))
//        path.addCurve(to: CGPoint(x: distance, y: 100), controlPoint1: CGPoint(x: distance/2, y: -125), controlPoint2: CGPoint(x: distance, y: 100))
//        return path
//    }
    private func showHelperAlertIfNeeded() {
        let key = "PlaneAnchorViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: "Plane Anchor", message: "Tap to search for a horizontal plane and, if found, attach a coffee mug to it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    func distanceBetweenPoints2(A: SCNVector3, B: SCNVector3) -> CGFloat {
        let l = sqrt(
            (A.x - B.x) * (A.x - B.x)
                +   (A.y - B.y) * (A.y - B.y)
                +   (A.z - B.z) * (A.z - B.z)
        )
        return CGFloat(l)
    }
    var touchedPoint = SCNVector3()
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if results.first != nil && viewFeatures.isEmpty{
            debugPrint(results.first)
            touchedPoint = results.first!.worldTransform.translation
            configureWorldBottom()
        }else{
            let hits = self.sceneView.hitTest(point, options: nil)
            if !hits.isEmpty{
                if let tappedNode = hits.first?.node{
                    debugPrint(tappedNode)
                    if let index = nodeFeatures.firstIndex(of: tappedNode){
                        debugPrint(index)
                        self.itemTouched(view: viewFeatures[index])
                    }
                }
            }
        }
    }
    func itemTouched(view: UIImageView) {
        let view = view
        var open = true
        for lbl in view.subviews{
            if (lbl.isKind(of: UILabel.self)){
                if lbl.isHidden{
                    lbl.isHidden = false
                    view.image = UIImage(named: "open_markerAR")
                    open = true
                }else{
                    lbl.isHidden = true
                    view.image = UIImage(named: "Collapsed_markerAR")
                    open = false
                }
            }
        }
        view.contentMode = .scaleAspectFit
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        for img in view.subviews{
            if (img.isKind(of: UIImageView.self)){
                if !open{
                    img.center = view.center
                }else{
                    img.frame.origin = CGPoint(x:15,y:10)
                }
            }
        }
        view.layoutIfNeeded()
    }
    //https://www.geeksforgeeks.org/bresenhams-algorithm-for-3-d-line-drawing/
    func Bresenham3D(starting:SCNVector3,ending:SCNVector3)->[SCNVector3]{
        var x1 = Int(starting.x)
        var y1 = Int(starting.y)
        var z1 = Int(starting.z)
        let x2 = Int(ending.x)
        let y2 = Int(ending.y)
        let z2 = Int(ending.z)
        var listOfPoints = [SCNVector3]()
        listOfPoints.append(starting)
        let dx = abs(x2 - x1)
        let dy = abs(y2 - y1)
        let dz = abs(z2 - z1)
        var xs = -1
        var ys = -1
        var zs = -1
        if (x2 > x1){
            xs = 1
        }
        if (y2 > y1){
            ys = 1
        }
        if (z2 > z1){
            zs = 1
        }
        //# Driving axis is X-axis"
        if (dx >= dy && dx >= dz){
            var p1 = 2 * dy - dx
            var p2 = 2 * dz - dx
            while (x1 != x2){
                x1 += xs
                if (p1 >= 0){
                    y1 += ys
                    p1 -= 2 * dx
                }
                if (p2 >= 0){
                    z1 += zs
                    p2 -= 2 * dx
                    p1 += 2 * dy
                    p2 += 2 * dz
                }
                listOfPoints.append(SCNVector3Make(Float(x1), Float(y1), Float(z1)))
            }
        //# Driving axis is Y-axis"
        }else if (dy >= dx && dy >= dz){
        var p1 = 2 * dx - dy
        var p2 = 2 * dz - dy
            while (y1 != y2){
                y1 += ys
                if (p1 >= 0){
                    x1 += xs
                    p1 -= 2 * dy
                }
                if (p2 >= 0){
                    z1 += zs
                    p2 -= 2 * dy
                    p1 += 2 * dx
                    p2 += 2 * dz
                }
                listOfPoints.append(SCNVector3Make(Float(x1), Float(y1), Float(z1)))
            }
        //# Driving axis is Z-axis"
        }else{
            var p1 = 2 * dy - dz
            var p2 = 2 * dx - dz
            while (z1 != z2){
                z1 += zs
                if (p1 >= 0){
                    y1 += ys
                    p1 -= 2 * dz
                }
                if (p2 >= 0){
                    x1 += xs
                    p2 -= 2 * dz
                    p1 += 2 * dy
                    p2 += 2 * dx
                }
                listOfPoints.append(SCNVector3Make(Float(x1), Float(y1), Float(z1)))
            }
        }
        return listOfPoints
    }
}

@available(iOS 11.0, *)
extension ARPlanViewController : CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (locations.last)!.coordinate
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
    }
}
/*@available(iOS 11.0, *)
extension ARPlanViewController : ARSCNViewDelegate {
    func update(planeNode: SCNNode, from planeAnchor: ARPlaneAnchor, hidden: Bool) {
        let updatedGeometry = plane(from: planeAnchor, hidden: hidden)
        planeNode.geometry = updatedGeometry
        planeNode.physicsBody?.physicsShape = SCNPhysicsShape(geometry: updatedGeometry, options: nil)
        planeNode.position = position(from: planeAnchor)
    }
    func generatePlaneFrom(planeAnchor: ARPlaneAnchor, physics: Bool, hidden: Bool) -> SCNNode {
        let plan = plane(from: planeAnchor, hidden: hidden)
        let planeNode = SCNNode(geometry: plan)
        planeNode.position = position(from: planeAnchor)
        if physics {
            let body = SCNPhysicsBody(type: .kinematic, shape: SCNPhysicsShape(geometry: plan, options: nil))
            body.restitution = 0.0
            body.friction = 1.0
            planeNode.physicsBody = body
        }
        return planeNode
    }
    func plane(from planeAnchor: ARPlaneAnchor, hidden: Bool) -> SCNGeometry {
        let plane = SCNBox(width: CGFloat(planeAnchor.extent.x), height: 0.005, length: CGFloat(planeAnchor.extent.z), chamferRadius: 0)
        
        let color = SCNMaterial()
        color.diffuse.contents = hidden ? UIColor(white: 1, alpha: 0) : UIColor(red: 0, green: 0, blue: 1, alpha: 0.5)
        plane.materials = [color]
        
        return plane
    }
    private func position(from planeAnchor: ARPlaneAnchor) -> SCNVector3 {
        return SCNVector3Make(planeAnchor.center.x, -0.005, planeAnchor.center.z)
    }

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        let planeNode = generatePlaneFrom(planeAnchor: planeAnchor, physics: true, hidden: false)
        node.addChildNode(planeNode)
        self.planes[key] = planeNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            update(planeNode: existingPlane, from: planeAnchor, hidden: false)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            existingPlane.removeFromParentNode()
            self.planes.removeValue(forKey: key)
        }
    }
}*/
@available(iOS 11.0, *)
extension ARPlanViewController : SCNPhysicsContactDelegate {
    func physicsWorld(_ world: SCNPhysicsWorld, didBegin contact: SCNPhysicsContact) {
        let mask = contact.nodeA.physicsBody!.categoryBitMask | contact.nodeB.physicsBody!.categoryBitMask
        if CollisionTypes(rawValue: mask) == [CollisionTypes.bottom, CollisionTypes.shape] {
            if contact.nodeA.physicsBody!.categoryBitMask == CollisionTypes.bottom.rawValue {
                contact.nodeB.removeFromParentNode()
            } else {
                contact.nodeA.removeFromParentNode()
            }
        }
    }
}
extension float4x4 {
    var translation: SCNVector3 {
        let translation = self.columns.3
        return SCNVector3(translation.x, translation.y, translation.z)
    }
}
