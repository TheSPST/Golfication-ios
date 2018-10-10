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

@available(iOS 11.0, *)
class ARPlanViewController: UIViewController {
    @IBOutlet var sceneView: ARSCNView!
    var planes = [SCNNode]()
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
//        sceneView.delegate = self
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
//extension ARPlanViewController:ARSCNViewDelegate{
//    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
//        if let arPlaneAnchor = anchor as? ARPlaneAnchor {
//            let plane = VirtualPlane(anchor: arPlaneAnchor)
//            self.planes[arPlaneAnchor.identifier] = plane
//            node.addChildNode(plane)
//        }
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
//        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let plane = planes[arPlaneAnchor.identifier] {
//            plane.updateWithNewAnchor(arPlaneAnchor)
//        }
//    }
//    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
//        if let arPlaneAnchor = anchor as? ARPlaneAnchor, let index = planes.index(forKey: arPlaneAnchor.identifier) {
//            planes.remove(at: index)
//        }
//    }
//}
@available(iOS 11.0, *)
class VirtualPlane: SCNNode {
    var anchor: ARPlaneAnchor!
    var planeGeometry: SCNPlane!
    init(anchor: ARPlaneAnchor) {
        super.init()
        
        // (1) initialize anchor and geometry, set color for plane
        self.anchor = anchor
        self.planeGeometry = SCNPlane(width: CGFloat(anchor.extent.x), height: CGFloat(anchor.extent.z))
        let material = initializePlaneMaterial()
        self.planeGeometry!.materials = [material]
        
        // (2) create the SceneKit plane node. As planes in SceneKit are vertical, we need to initialize the y coordinate to 0,
        // use the z coordinate, and rotate it 90º.
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi / 2.0, 1.0, 0.0, 0.0)
        
        // (3) update the material representation for this plane
        updatePlaneMaterialDimensions()
        
        // (4) add this node to our hierarchy.
        self.addChildNode(planeNode)
    }
    func initializePlaneMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.white.withAlphaComponent(0.50)
        return material
    }
    func updatePlaneMaterialDimensions() {
        // get material or recreate
        let material = self.planeGeometry.materials.first!
        
        // scale material to width and height of the updated plane
        let width = Float(self.planeGeometry.width)
        let height = Float(self.planeGeometry.height)
        material.diffuse.contentsTransform = SCNMatrix4MakeScale(width, height, 1.0)
    }
    func updateWithNewAnchor(_ anchor: ARPlaneAnchor) {
        // first, we update the extent of the plane, because it might have changed
        self.planeGeometry.width = CGFloat(anchor.extent.x)
        self.planeGeometry.height = CGFloat(anchor.extent.z)
        
        // now we should update the position (remember the transform applied)
        self.position = SCNVector3(anchor.center.x, 0, anchor.center.z)
        
        // update the material representation for this plane
        updatePlaneMaterialDimensions()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
