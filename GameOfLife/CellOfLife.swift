//
//  CellOfLife.swift
//  GameOfLife
//
//  Created by Zach Eriksen on 9/16/18.
//  Copyright © 2018 oneleif. All rights reserved.
//

import SceneKit

class CellOfLife: SCNNode {
    // A default alive color the cells will use
    private let aliveColor = UIColor.white.withAlphaComponent(0.75)
    // The box that will represent the cell
    private var boxNode: SCNNode
    // A color that can be set and the box will use
    public var color: UIColor? {
        didSet {
            self.boxNode.geometry?.firstMaterial?.diffuse.contents = color ?? aliveColor
        }
        
    }
    // If the cell is dead the box will be hidden
    public var isAlive: Bool {
        didSet {
            boxNode.isHidden = !isAlive
        }
    }
    
    // Creates a cell with a SCNBox
    init(isAlive alive: Bool, nodeWidth: CGFloat, nodeHeight: CGFloat) {
        let box = SCNBox(width: nodeWidth, height: nodeHeight, length: nodeWidth, chamferRadius: 0)
        // Set the firstMaterial to the aliveColor
        box.firstMaterial?.diffuse.contents = aliveColor
        boxNode = SCNNode(geometry: box)
        isAlive = alive
        super.init()
        addChildNode(boxNode)
        boxNode.isHidden = !isAlive
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
