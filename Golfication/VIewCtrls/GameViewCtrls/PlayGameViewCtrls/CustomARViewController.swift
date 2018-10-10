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
     
    var locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var heading = Double()
    let configuration = ARWorldTrackingConfiguration()
    @IBOutlet weak var sceneView: ARSCNView!
    var places = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sceneView.autoenablesDefaultLighting = true
        sceneView.showsStatistics = true
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
    
    private var mugs: Set<String> = []
    
    @IBAction func tapScreen(sender: UITapGestureRecognizer) {
        guard sender.state == .ended else { return }
        
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        
        print(results)
        
        if let match = results.first {
            let box = SCNBox(width: 0.1, height: 0.5, length: 0.1, chamferRadius: 0)
            let boxNode = SCNNode(geometry:box)
            let t = match.worldTransform
            let anchor = ARAnchor(transform: match.worldTransform)
            self.sceneView.session.add(anchor: anchor)
            debugPrint(t)
            boxNode.position = SCNVector3(x: t.columns.3.x, y: t.columns.3.y, z: t.columns.3.z)
            self.sceneView.scene.rootNode.addChildNode(boxNode)
            calculateOtherCoordinates(t:match)
        }
    }
    var distanceHeading = [(head:Double,dist:Double)]()
    func calculateOtherCoordinates(t:ARHitTestResult){
        debugPrint(places)
        debugPrint(heading)
        debugPrint(currentLocation)
        let teePosition = places[0].location!.coordinate
        for data in places{
            if let location = data.location{
                debugPrint(location.coordinate)
                let distance = GMSGeometryDistance(teePosition, location.coordinate)
                let head = GMSGeometryHeading(teePosition, location.coordinate)
                distanceHeading.append((head: head, dist: distance))
                addMoreScenes(t: t, text: data.placeName,head:head,distance:distance)
            }
        }
        
    }
    func addMoreScenes(t:ARHitTestResult,text:String,head:Double,distance:Double){
        let text = SCNText(string: "\(text) \(Int(distance/2))", extrusionDepth: 4)
        let textNode = SCNNode(geometry: text)
        textNode.geometry = text
        let data = transform(rotationY: Float(head), distance: Int(distance/2))
        let dataInto = float4x4(data)
        textNode.position = SCNVector3(x: dataInto.columns.3.x, y: dataInto.columns.3.y, z: dataInto.columns.3.z)
        debugPrint(SCNVector3(x: dataInto.columns.3.x, y: dataInto.columns.3.y, z: dataInto.columns.3.z))
        debugPrint(t)
        let anchor = ARAnchor(transform: t.worldTransform)
        self.sceneView.session.add(anchor: anchor)
        self.sceneView.scene.rootNode.addChildNode(textNode)
    }
    func transform(rotationY: Float, distance: Int) -> SCNMatrix4 {
        
        // Translate first on -z direction
        let translation = SCNMatrix4MakeTranslation(0, 0, Float(-distance))
        // Rotate (yaw) around y axis
        let rotation = SCNMatrix4MakeRotation(-1 * rotationY, 0, 1, 0)
        
        // Final transformation: TxR
        let transform = SCNMatrix4Mult(translation, rotation)
        
        return transform
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
        debugPrint(heading)
        debugPrint(self.sceneView.scene)
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
extension CustomARViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer,didAdd node: SCNNode,for anchor: ARAnchor) {
        debugPrint(node)
        debugPrint(anchor)
    }
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        debugPrint(time)
    }
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        debugPrint(node)
        debugPrint(anchor)
    }
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        debugPrint(node)
        debugPrint(anchor)
    }
}
