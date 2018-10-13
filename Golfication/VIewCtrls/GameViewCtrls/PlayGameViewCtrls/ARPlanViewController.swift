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

struct CollisionTypes : OptionSet {
    let rawValue: Int
    
    static let bottom  = CollisionTypes(rawValue: 1 << 0)
    static let shape = CollisionTypes(rawValue: 1 << 1)
}

@available(iOS 11.0, *)
class ARPlanViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var places = [Place]()
    var planes: [String : SCNNode] = [:]
    var bottomNode = SCNNode()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ARWorldTrackingConfiguration.isSupported {
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Plane Mapper"
        
        self.sceneView.antialiasingMode = .multisampling4X
//        self.sceneView.delegate = self
        self.sceneView.autoenablesDefaultLighting = true
    }
    
    private func configureWorldBottom() {
        let bottomPlane = SCNBox(width: 1000, height: 0.005, length: 1000, chamferRadius: 0)
        
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.glfBluegreen
        bottomPlane.materials = [material]
        
        self.bottomNode = SCNNode(geometry: bottomPlane)
        bottomNode.position = SCNVector3(x: 0, y: -5, z: 0)
        
        let physicsBody = SCNPhysicsBody.static()
        physicsBody.categoryBitMask = CollisionTypes.bottom.rawValue
        physicsBody.contactTestBitMask = CollisionTypes.shape.rawValue
        bottomNode.physicsBody = physicsBody
        
        self.sceneView.scene.rootNode.addChildNode(bottomNode)
        self.sceneView.scene.physicsWorld.contactDelegate = self
        self.calculateOtherCoordinates()
    }
    
    var nodeDetails = [(name:String,vector:SCNVector3)]()
    func addMoreScenes(text:String,head:Double,distance:Double){
        let textScene = SCNText(string: "\(text) \(Int(distance))", extrusionDepth: 2)
        let textNode = SCNNode(geometry: textScene)
        textNode.geometry = textScene
        let data = transform(rotationY: Float(head), distance: Int(distance))
        let dataInto = float4x4(data)
        textNode.position = SCNVector3(x: dataInto.columns.3.x, y: 0, z: dataInto.columns.3.z)
        self.bottomNode.addChildNode(textNode)
        nodeDetails.append((name:text,vector:textNode.position))
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
    var distanceHeading = [(head:Double,dist:Double)]()
    func calculateOtherCoordinates(){
        debugPrint(places)
        let teePosition = places[0].location!.coordinate
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
        let starting = SCNVector3()
        var ending = SCNVector3()
        for data in nodeDetails{
            if data.name.contains("Bunker"){
                ending = data.vector
                break
            }
        }
        let distance = distanceBetweenPoints2(A: starting, B: ending)
        let geometry = SCNTorus(ringRadius: CGFloat(distance/2), pipeRadius: 0.1)
        geometry.materials.first?.diffuse.contents = UIColor.blue
        let ring = SCNNode(geometry: geometry)
        self.bottomNode.addChildNode(ring)
        ring.rotation = SCNVector4Make(0, 1, 0, 90)
        ring.rotation = SCNVector4Make(1, 0, 0, 90)
        
//        ring.runAction(SCNAction.rotate(by: 90, around: SCNVector3(x:0,y:0,z:0), duration: 0.0))
//        let mate = SCNMaterial()
//        mate.diffuse.contents = UIColor.red
//        let curvedLine = LineNode(v1: starting, v2: ending, material: [mate])
//        self.bottomNode.addChildNode(curvedLine)
//        self.createLine(startPosition: starting, endPosition: ending)
    }
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
    @IBAction func tapScreen(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: self.sceneView)
        let results = self.sceneView.hitTest(point, types: [.existingPlaneUsingExtent, .estimatedHorizontalPlane])
        if let match = results.first {
            configureWorldBottom()
        }
    }
}

@available(iOS 11.0, *)
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
}
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
//@available(iOS 11.0, *)
//class LineNode: SCNNode{
//    init(v1: SCNVector3,v2: SCNVector3,material: [SCNMaterial] ){
//        super.init()
//        let  height1 = self.distanceBetweenPoints2(A: v1, B: v2) as CGFloat //v1.distance(v2)
//        position = v1
//        let ndV2 = SCNNode()
//        ndV2.position = v2
//        let ndZAlign = SCNNode()
//        ndZAlign.eulerAngles.x = Float.pi/2
//        let cylgeo = SCNBox(width: 0.02, height: height1, length: 0.001, chamferRadius: 0)
//        cylgeo.materials = material
//        let ndCylinder = SCNNode(geometry: cylgeo )
//        ndCylinder.position.y = Float(-height1/2) + 0.001
//        ndZAlign.addChildNode(ndCylinder)
//        addChildNode(ndZAlign)
//        constraints = [SCNLookAtConstraint(target: ndV2)]
//    }
//
//    override init() {
//        super.init()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//}
