//
//  CustomARViewController.swift
//  Golfication
//
//  Created by Khelfie on 08/10/18.
//  Copyright © 2018 Khelfie. All rights reserved.
//

import UIKit
import ARKit
import SceneKit
import CoreLocation
import GoogleMaps
@available(iOS 11.0, *)
class CustomARViewController: UIViewController,CLLocationManagerDelegate{
    fileprivate var planes: [String : SCNNode] = [:]
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var heading = Double()
    let configuration = ARWorldTrackingConfiguration()
    @IBOutlet weak var sceneView: ARSCNView!
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.showsStatistics = true
        sceneView.antialiasingMode = .multisampling4X
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.worldAlignment = .gravityAndHeading
            self.sceneView.session.run(configuration)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.showHelperAlertIfNeeded()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.sceneView.session.pause()
    }
    
    // MARK: - UI Events
    var distanceHeading = [(head:Double,dist:Double)]()
    func calculateOtherCoordinates(t:ARHitTestResult){
        debugPrint(places)
        debugPrint(heading)
        debugPrint(currentLocation)
        let teePosition = currentLocation
//places[0].location!.coordinate
        
        nodeDetails.removeAll()
        for data in places{
            if let location = data.location{
                debugPrint(location.coordinate)
                let distance = GMSGeometryDistance(teePosition, location.coordinate)
                let head = GMSGeometryHeading(teePosition, location.coordinate)
                distanceHeading.append((head: head, dist: distance))
                addMoreScenes(t: t, text: data.placeName,head:head,distance:distance)
            }
        }
       /* let starting = SCNVector3()
        var ending = SCNVector3()
        for data in nodeDetails{
            if data.name.contains("Bunker"){
                ending = data.vector
                break
            }
        }
        self.createLine(startPosition: starting, endPosition: ending)*/
    }
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        
        print(results)
        
        if let match = results.first {
//            let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
//            let boxNode = SCNNode()
//            boxNode.geometry = box
//            let t = match.worldTransform
//            boxNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
//            self.sceneView.scene.rootNode.addChildNode(boxNode)
            calculateOtherCoordinates(t:match)
        }
    }
    var nodeDetails = [(name:String,vector:SCNVector3)]()
    func addMoreScenes(t:ARHitTestResult,text:String,head:Double,distance:Double){
        let textScene = SCNText(string: "\(text) \(Int(distance))", extrusionDepth: 4)
        textScene.alignmentMode = kCAAlignmentCenter
        let textNode = SCNNode(geometry: textScene)
        textNode.geometry = textScene
        textNode.position = transform(t:t,rotationY: head, distance: distance)
        debugPrint("Position of : \(text) Head : \(head) , Distance : \(distance), Points : \(textNode.position)")
        
//        let data = transform(rotationY: head, distance: distance)
//        let dataInto = float4x4(data)
//        textNode.position = SCNVector3(x: dataInto.columns.3.x, y: dataInto.columns.3.y, z: dataInto.columns.3.z)
//        debugPrint(SCNVector3(x: dataInto.columns.3.x, y: dataInto.columns.3.y, z: dataInto.columns.3.z))
//        debugPrint(t)
        let anchor = ARAnchor(transform: t.worldTransform)
        self.sceneView.session.add(anchor: anchor)
        self.sceneView.scene.rootNode.addChildNode(textNode)
        nodeDetails.append((name:text,vector:textNode.position))
    }
    
    func transform(t:ARHitTestResult,rotationY: Double, distance: Double) -> SCNVector3 {
        debugPrint("Angle in Radian : \(degreesToRadians(rotationY))")
        let x = Float(distance*sin(degreesToRadians(rotationY)))
        let z = Float(-distance*cos(degreesToRadians(rotationY)))
        let transform = SCNVector3(x:x,y:0,z:z)
        return transform
    }
    
    func transform(rotationY: Double, distance: Double) -> SCNMatrix4 {
        // Translate first on -z direction
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
        // Rotate (yaw) around y axis
        let rotation = SCNMatrix4MakeRotation(-1 * Float(rotationY), 0, 1, 0)
        // Final transformation: TxR
        let transform = SCNMatrix4Mult(translation, rotation)
        return transform
    }

    func createLine(startPosition:SCNVector3,endPosition:SCNVector3){
        debugPrint(startPosition)
        debugPrint(endPosition)
        let twoPointsNode1 = SCNNode()
        self.sceneView.scene.rootNode.addChildNode(twoPointsNode1.buildLineInTwoPointsWithRotation(
            from: startPosition, to: endPosition, radius: 0.2, color: .cyan))
//        let cubeNode = SCNNode(geometry: SCNBox(width: 0.05, height: 0.05, length: CGFloat(endPosition.z), chamferRadius: 0.1))
//        cubeNode.position = SCNVector3(0, -1, -(CGFloat(endPosition.z/2))) // SceneKit/AR coordinates are in meters
//        sceneView.scene.rootNode.addChildNode(cubeNode)
//
//
//        let line = SCNGeometry.line(from: startPosition, to: endPosition)
//        let lineNode = SCNNode(geometry: line)
//        lineNode.position = SCNVector3Zero
//        self.sceneView.scene.rootNode.addChildNode(lineNode)
    }
    // MARK: - Private Methods
    
    private func showHelperAlertIfNeeded() {
        let key = "PlaneAnchorViewController.helperAlert.didShow"
        if !UserDefaults.standard.bool(forKey: key) {
            let alert = UIAlertController(title: "Plane Anchor", message: "Tap to search for a horizontal plane and, if found, attach a coffee mug to it.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
            UserDefaults.standard.set(true, forKey: key)
        }
    }
    

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = (locations.last)!.coordinate
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        heading = newHeading.trueHeading
//        debugPrint(heading)
//        debugPrint(self.sceneView.scene)
    }
    func addBox(x:Double,y:Double,z:Double) {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        
        let boxNode = SCNNode()
        boxNode.geometry = box
        boxNode.position = SCNVector3(x, y, z)
        
        let scene = SCNScene()
        scene.rootNode.addChildNode(boxNode)
        sceneView.scene = scene
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        debugPrint(error)
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        debugPrint(session)
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        debugPrint(session)
    }

}
extension float4x4 {
    init(_ matrix: SCNMatrix4) {
        self.init([
            float4(matrix.m11, matrix.m12, matrix.m13, matrix.m14),
            float4(matrix.m21, matrix.m22, matrix.m23, matrix.m24),
            float4(matrix.m31, matrix.m32, matrix.m33, matrix.m34),
            float4(matrix.m41, matrix.m42, matrix.m43, matrix.m44)
            ])
    }
}

extension float4 {
    init(_ vector: SCNVector4) {
        self.init(vector.x, vector.y, vector.z, vector.w)
    }
    
    init(_ vector: SCNVector3) {
        self.init(vector.x, vector.y, vector.z, 1)
    }
}

extension SCNVector4 {
    init(_ vector: float4) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: vector.w)
    }
    
    init(_ vector: SCNVector3) {
        self.init(x: vector.x, y: vector.y, z: vector.z, w: 1)
    }
}

extension SCNVector3 {
    init(_ vector: float4) {
        self.init(x: vector.x / vector.w, y: vector.y / vector.w, z: vector.z / vector.w)
    }
}

func * (left: SCNMatrix4, right: SCNVector3) -> SCNVector3 {
    let matrix = float4x4(left)
    let vector = float4(right)
    let result = matrix * vector
    
    return SCNVector3(result)
}
@available(iOS 11.0, *)
extension CustomARViewController : ARSCNViewDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        // This visualization covers only detected planes.
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        // Create a SceneKit plane to visualize the node using its position and extent.
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = SCNVector3Make(planeAnchor.center.x, 0, planeAnchor.center.z)
        
        // SCNPlanes are vertically oriented in their local coordinate space.
        // Rotate it to match the horizontal orientation of the ARPlaneAnchor.
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2, 1, 0, 0)
        
        // ARKit owns the node corresponding to the anchor, so make the plane a child node.
        node.addChildNode(planeNode)
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard anchor is ARPlaneAnchor else { return }
//        let key = anchor.identifier.uuidString
//        if let existingPlane = self.planes[key] {
//            NodeGenerator.update(planeNode: existingPlane, from: anchor, hidden: !self.showPlanes)
//        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        let key = planeAnchor.identifier.uuidString
        if let existingPlane = self.planes[key] {
            existingPlane.removeFromParentNode()
            self.planes.removeValue(forKey: key)
        }
    }
}
@available(iOS 11.0, *)
extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}


extension SCNNode {
    func normalizeVector(_ iv: SCNVector3) -> SCNVector3 {
        let length = sqrt(iv.x * iv.x + iv.y * iv.y + iv.z * iv.z)
        if length == 0 {
            return SCNVector3(0.0, 0.0, 0.0)
        }
        
        return SCNVector3( iv.x / length, iv.y / length, iv.z / length)
        
    }
    func buildLineInTwoPointsWithRotation(from startPoint: SCNVector3,
                                          to endPoint: SCNVector3,
                                          radius: CGFloat,
                                          color: UIColor) -> SCNNode {
        let w = SCNVector3(x: endPoint.x-startPoint.x,
                           y: endPoint.y-startPoint.y,
                           z: endPoint.z-startPoint.z)
        let l = CGFloat(sqrt(w.x * w.x + w.y * w.y + w.z * w.z))
        
        if l == 0.0 {
            // two points together.
            let sphere = SCNSphere(radius: radius)
            sphere.firstMaterial?.diffuse.contents = color
            self.geometry = sphere
            self.position = startPoint
            return self
            
        }
        
        let cyl = SCNCylinder(radius: radius, height: l)
        cyl.firstMaterial?.diffuse.contents = color
        
        self.geometry = cyl
        
        //original vector of cylinder above 0,0,0
        let ov = SCNVector3(0, l/2.0,0)
        //target vector, in new coordination
        let nv = SCNVector3((endPoint.x - startPoint.x)/2.0, (endPoint.y - startPoint.y)/2.0,
                            (endPoint.z-startPoint.z)/2.0)
        
        // axis between two vector
        let av = SCNVector3( (ov.x + nv.x)/2.0, (ov.y+nv.y)/2.0, (ov.z+nv.z)/2.0)
        
        //normalized axis vector
        let av_normalized = normalizeVector(av)
        let q0 = Float(0.0) //cos(angel/2), angle is always 180 or M_PI
        let q1 = Float(av_normalized.x) // x' * sin(angle/2)
        let q2 = Float(av_normalized.y) // y' * sin(angle/2)
        let q3 = Float(av_normalized.z) // z' * sin(angle/2)
        
        let r_m11 = q0 * q0 + q1 * q1 - q2 * q2 - q3 * q3
        let r_m12 = 2 * q1 * q2 + 2 * q0 * q3
        let r_m13 = 2 * q1 * q3 - 2 * q0 * q2
        let r_m21 = 2 * q1 * q2 - 2 * q0 * q3
        let r_m22 = q0 * q0 - q1 * q1 + q2 * q2 - q3 * q3
        let r_m23 = 2 * q2 * q3 + 2 * q0 * q1
        let r_m31 = 2 * q1 * q3 + 2 * q0 * q2
        let r_m32 = 2 * q2 * q3 - 2 * q0 * q1
        let r_m33 = q0 * q0 - q1 * q1 - q2 * q2 + q3 * q3
        
        self.transform.m11 = r_m11
        self.transform.m12 = r_m12
        self.transform.m13 = r_m13
        self.transform.m14 = 0.0
        
        self.transform.m21 = r_m21
        self.transform.m22 = r_m22
        self.transform.m23 = r_m23
        self.transform.m24 = 0.0
        
        self.transform.m31 = r_m31
        self.transform.m32 = r_m32
        self.transform.m33 = r_m33
        self.transform.m34 = 0.0
        
        self.transform.m41 = (startPoint.x + endPoint.x) / 2.0
        self.transform.m42 = (startPoint.y + endPoint.y) / 2.0
        self.transform.m43 = (startPoint.z + endPoint.z) / 2.0
        self.transform.m44 = 1.0
        return self
    }
}
