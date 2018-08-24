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

class ViewController: UIViewController, ARSCNViewDelegate {
    let referenceImageGroupName = "mountains"
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    @IBOutlet weak var sceneView: SceneView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
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
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor else { return }
        let referenceImage = imageAnchor.referenceImage
        updateQueue.async {
            let plane = SCNPlane(width: referenceImage.physicalSize.width,
                                 height: referenceImage.physicalSize.height)
            let planeNode = SCNNode(geometry: plane)
            planeNode.opacity = 0.25
            planeNode.eulerAngles.x = -.pi / 2
            planeNode.runAction(self.imageHighlightAction)
            
            // Add the plane visualization to the scene.
            node.addChildNode(planeNode)
        }
        let imageName = referenceImage.name ?? ""
        print("Detected image “\(imageName)”")
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
}
