//
//  ViewController.swift
//  AR My House
//
//  Created by Michael Tseitlin on 5/18/19.
//  Copyright © 2019 Michael Tseitlin. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Enable default lighting
        sceneView.autoenablesDefaultLighting = true

        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        //Place yardes
        placeYard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }

}

// MARK: - Placing 3D Object
extension ViewController {
    
    func placeYard() {
        let scene = SCNScene(named: "art.scnassets/Yard.scn")!
        let node = scene.rootNode.clone()
        
        node.position = SCNVector3(0, -10, -25)
        node.eulerAngles.y = -.pi / 8
  
        let trees = getTreesWithPositions()
        addChilds(to: node, array: trees)
        
        sceneView.scene.rootNode.addChildNode(node)
    }
    
    func addChilds(to node: SCNNode, array: [SCNNode]) {
        for tree in array {
            node.addChildNode(tree)
        }
    }
    
    func getTreesWithPositions() -> [SCNNode]{
        var startPosition = SCNVector3(7, 2.5, -10)
        var arrayOfTrees = [SCNNode]()
        for _ in 0...2 {
            let tree = getTreeNode()
            startPosition.z += 5
            tree.position = startPosition
            arrayOfTrees.append(tree)
        }
        return arrayOfTrees
    }
    
    func getTreeNode() -> SCNNode {
        let bark = getBarkNode()
        bark.eulerAngles.x = -.pi / 2
        
        let leaves = getLeavesNode()
        leaves.position.y = -2
        
        let tree = SCNNode()
        tree.eulerAngles.x = -.pi / 2
        
        bark.addChildNode(leaves)
        tree.addChildNode(bark)
        
        return tree
    }
    
    func getBarkNode() -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.3, height: 5)
        cylinder.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        
        let bark = SCNNode(geometry: cylinder)
        
        return bark
    }
    
    func getLeavesNode() -> SCNNode {
        let sphere = SCNSphere(radius: 2)
        sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        let leaves = SCNNode(geometry: sphere)
        
        return leaves
    }
}
