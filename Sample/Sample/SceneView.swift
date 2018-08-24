//
//  SceneView.swift
//  Sample
//
//  Created by Alexey Vedushev on 16/08/2018.
//  Copyright © 2018 Alexey Vedushev. All rights reserved.
//

import UIKit
import ARKit

class SceneView: ARSCNView {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }
        
        if let hit = hitTest(location, types: .estimatedHorizontalPlane).first {
            session.add(anchor: ARAnchor(transform: hit.worldTransform))
        }
    }
}
