//
//  ViewController.swift
//  Sample
//
//  Created by Alexey Vedushev on 16/08/2018.
//  Copyright © 2018 Alexey Vedushev. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class MainVC: UIViewController, ARSCNViewDelegate {
    let referenceImageGroupName = "mountains"
    let youNoticiedImageSize = CGSize(width: 0.23, height: 0.125)
    let headphoneIdentity = "headphone"
    let boxSize: CGFloat = 0.2
    
    let headPhoneScene = SCNScene(named: "headphone.scnassets/default.scn")!.rootNode
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    @IBOutlet weak var sceneView: SceneView!
    
    var scnBox: SCNBox!
    
    var session: ARSession {
        return sceneView.session
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    private func setupBox() {
        scnBox = SCNBox(width: boxSize, height: boxSize, length: boxSize, chamferRadius: 0)
        scnBox.firstMaterial?.diffuse.contents = UIColor.cyan
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    func resetTracking() {
        guard let referenceImage = ARReferenceImage.referenceImages(inGroupNamed: referenceImageGroupName, bundle: nil) else {
            fatalError("Missing expected asset catalog resources.")
        }
        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = referenceImage
        
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - ARSCNViewDelegate
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        if let hitTestresult = hitTest(CGPoint(x: view.bounds.midX, y: view.bounds.midY)), let anchor = hitTestresult.anchor {
            session.add(anchor: anchor)
            
            if let box = sceneView.scene.rootNode.childNodes.first{$0 === scnBox} {
                
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        didAddImageDetectionNode(didAdd: node, for: anchor)
        
    }

    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    var imageHighlightAction: SCNAction {
        return .sequence([
            .wait(duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOpacity(to: 0.15, duration: 0.25),
            .fadeOpacity(to: 0.85, duration: 0.25),
            .fadeOut(duration: 0.5),
            .removeFromParentNode()
            ])
    }
    
    private func hitTest(_ point: CGPoint) -> ARHitTestResult? {
        let results = sceneView.hitTest(point, types: [.existingPlaneUsingGeometry, .estimatedVerticalPlane, .estimatedHorizontalPlane])
        
        if let existingPlaneUsingGeometryResult = results.first(where: { $0.type == .existingPlaneUsingGeometry}) {
            return existingPlaneUsingGeometryResult
        }
        return results.first
    }
    
    private func didAddImageDetectionNode(didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        
        let referenceImage = imageAnchor.referenceImage
        
        updateQueue.async { [weak self] in
            guard let self = self else { return }
            let plane = SCNPlane(width: self.youNoticiedImageSize.width,
                                 height: self.youNoticiedImageSize.height)
            print("width = \(referenceImage.physicalSize.width) height = \(referenceImage.physicalSize.height)")
            let material = SCNMaterial()
            material.diffuse.contents = UIImage(named: "you-noticed")!
            plane.materials = [material]
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            planeNode.eulerAngles.x = -.pi / 2
            //            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
        }
        let imageName = referenceImage.name ?? ""
        print("Detected image “\(imageName)”")
    }
}


extension float4x4 {
    /**
     Treats matrix as a (right-hand column-major convention) transform matrix
     and factors out the translation component of the transform.
     */
    var translation: float3 {
        get {
            let translation = columns.3
            return float3(translation.x, translation.y, translation.z)
        }
        set(newValue) {
            columns.3 = float4(newValue.x, newValue.y, newValue.z, columns.3.w)
        }
    }
    
    /**
     Factors out the orientation component of the transform.
     */
    var orientation: simd_quatf {
        return simd_quaternion(self)
    }
    
    /**
     Creates a transform matrix with a uniform scale factor in all directions.
     */
    init(uniformScale scale: Float) {
        self = matrix_identity_float4x4
        columns.0.x = scale
        columns.1.y = scale
        columns.2.z = scale
    }
}
