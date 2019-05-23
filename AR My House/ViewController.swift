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
    
    private var placeCounter = 0
    private var isYardPlaced = false
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Enable default lighting
        sceneView.autoenablesDefaultLighting = true
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Enable plane detection
        configuration.planeDetection = [.horizontal]
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
}

// MARK: - Custom methods
extension ViewController {
    private func addYard(at result: ARHitTestResult) {
        let yardScene = SCNScene(named: "art.scnassets/Yard.scn")
        guard let yardNode = yardScene?.rootNode.childNode(withName: "Yard", recursively: false) else { return }
        
        yardNode.simdTransform = result.worldTransform
        yardNode.scale = SCNVector3(0.02, 0.02, 0.02)
        
        //Add trees to the yard
        let trees = getTreesWithPositions()
        addChilds(to: yardNode, array: trees)
        
        //Remove all copies
        sceneView.scene.rootNode.enumerateChildNodes { node, _ in
            if node.name == "Yard"{
                node.removeFromParentNode()
            }
        }
        
        //Add yard to the scene
        sceneView.scene.rootNode.addChildNode(yardNode)
        isYardPlaced = true
    }
    
    private func createFloor(planeAnchor: ARPlaneAnchor) -> SCNNode {
        let extent = planeAnchor.extent
        let width = CGFloat(extent.x)
        let height = CGFloat(extent.z)
        
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = UIColor.blue
        
        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -.pi / 2
        node.opacity = 0.125
        
        return node
    }
    
    private func addChilds(to node: SCNNode, array: [SCNNode]) {
        for tree in array {
            node.addChildNode(tree)
        }
    }
    
    private func getTreesWithPositions() -> [SCNNode]{
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
    
    private func getTreeNode() -> SCNNode {
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
    
    private func getBarkNode() -> SCNNode {
        let cylinder = SCNCylinder(radius: 0.3, height: 5)
        cylinder.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.3098039329, green: 0.2039215714, blue: 0.03921568766, alpha: 1)
        
        let bark = SCNNode(geometry: cylinder)
        
        return bark
    }
    
    private func getLeavesNode() -> SCNNode {
        let sphere = SCNSphere(radius: 2)
        sphere.firstMaterial?.diffuse.contents = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1)
        
        let leaves = SCNNode(geometry: sphere)
        
        return leaves
    }
}

// MARK: - IB Actions
extension ViewController {
    @IBAction func screenTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: sceneView)
        guard let result = sceneView.hitTest(location, types: [.existingPlaneUsingExtent]).first else { return }
        addYard(at: result)
    }
}

// MARK: - ARSCNViewDelegate
extension ViewController {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        guard !isYardPlaced else { return }
        
        let floor = createFloor(planeAnchor: planeAnchor)
        floor.name = "Yard"
        node.addChildNode(floor)
        
        placeCounter += 1
        print(placeCounter)
    }
}
