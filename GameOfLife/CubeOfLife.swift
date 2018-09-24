//
//  CubeOfLife.swift
//  GameOfLife
//
//  Created by Zach Eriksen on 9/16/18.
//  Copyright © 2018 oneleif. All rights reserved.
//

import SceneKit

let bug = [float3(x: 0, y: 0, z: 1),
              float3(x: 0, y: 0, z: 0),
              float3(x: -1, y: 0, z: 0),
              float3(x: 1, y: 0, z: 0),
              float3(x: 0, y: -1, z: 0),
              float3(x: 0, y: 1, z: 0)]
let bomb = [float3(x: -2, y: 0, z: 2), float3(x: -2, y: 0, z: 3),
            float3(x: -1, y: 0, z: 2), float3(x: -1, y: 0, z: 3),
            float3(x: 1, y: 0, z: 2), float3(x: 1, y: 0, z: 3),
            float3(x: 2, y: 0, z: 2), float3(x: 2, y: 0, z: 3),
            
            float3(x: 0, y: 0, z: 2), float3(x: 0, y: 0, z: 3), float3(x: 0, y: 0, z: 4),
            
            float3(x: 0, y: -2, z: 2), float3(x: 0, y: -2, z: 3),
            float3(x: 0, y: -1, z: 2), float3(x: 0, y: -1, z: 3),
            float3(x: 0, y: 1, z: 2), float3(x: 0, y: 1, z: 3),
            float3(x: 0, y: 2, z: 2), float3(x: 0, y: 2, z: 3)]

class CubeOfLife: SCNNode {
    var life: [[[Bool]]] = []
    var cellsOfLife: [[[CellOfLife]]] = []
    var size: Int
    var zSize: Int
    var width: CGFloat
    var height: CGFloat
    var isBuilt = false
    
    init(n: Int, width: CGFloat, height: CGFloat, withAliveCells cells: [float3]? = nil, nHeight: Int = 5) {
        self.size = n
        self.zSize = nHeight
        self.width = width
        self.height = height
        super.init()
        
        setupLife(withAliveCells: cells)
    }
    
    private func setupLife(withAliveCells cellLocations: [float3]? = nil) {
        for x in (0 ..< size) {
            var plane: [[Bool]] = []
            for y in (0 ..< size) {
                var row: [Bool] = []
                for z in (0 ..< zSize) {
                    if let cells = cellLocations {
                        // Center the Location
                        let count = cells.filter { Int($0.x) + Int(size / 2) == x &&
                                                    Int($0.y) + Int(size / 2) == y &&
                                                    Int($0.z + 1) == z }
                        row.append(!count.isEmpty)
                        
                    } else {
                        // Random!
                        row.append(Bool.random())
                    }
                }
                plane.append(row)
            }
            life.append(plane)
        }
    }
    
    func build() {
        for x in (0 ..< size) {
            var plane: [[CellOfLife]] = []
            for y in (0 ..< size) {
                var row: [CellOfLife] = []
                for z in (0 ..< zSize) {
                    // Get if the cell is alive
                    let isAlive = life[x][y][z]
                    // Get the width and height
                    let nodeWidth = width / CGFloat(size)
                    let nodeHeight = height / CGFloat(size)
                    // Create the basic cell
                    let cell = CellOfLife(isAlive: isAlive, nodeWidth: nodeWidth, nodeHeight: nodeHeight)
                    // Set the postion for the cell
                    cell.position =  SCNVector3((CGFloat(x) * nodeWidth) - width / 2, (CGFloat(y) * nodeHeight) - width / 2, CGFloat(z) * nodeWidth)
                    // Calculate the distance from the center
                    let node1Pos = SCNVector3ToGLKVector3(cell.position)
                    let node2Pos = SCNVector3ToGLKVector3(SCNVector3(CGFloat(position.x) + nodeWidth / 2, CGFloat(position.y) + nodeHeight / 2, CGFloat(position.z) + nodeWidth / 2))
                    let distance = GLKVector3Distance(node1Pos, node2Pos)
                    // Set the color of the box
                    let color = UIColor(red: CGFloat(255 - (x * 10)) / 255.0, green: CGFloat(255 - (y * 10)) / 255.0, blue: CGFloat(255 - (z * 10)) / 255.0, alpha: CGFloat(1 - distance))
                    cell.color = color
                    // Add the cell to the cube of life
                    addChildNode(cell)
                    row.append(cell)
                }
                
                plane.append(row)
            }
            cellsOfLife.append(plane)
        }
        // The cube has been built
        isBuilt = true
        // Start the timer
        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
    }
    
    func update() {
        for x in (0 ..< size) {
            for y in (0 ..< size) {
                for z in (0 ..< zSize) {
                    let cell = cellsOfLife[x][y][z]
                    let isAlive = life[x][y][z]
                    cell.isAlive = isAlive
                }
            }
        }
    }
    
    @objc
    func tick() {
        var newGen: [[[Bool]]] = []
        for x in (0 ..< size) {
            var plane: [[Bool]] = []
            for y in (0 ..< size) {
                var row: [Bool] = []
                for z in (0 ..< zSize) {
                    let neighbors: [Bool?] = [
                        // Bottom
                        get(x-1, y-1, z-1),
                        get(x, y-1, z-1),
                        get(x, y, z-1),
                        get(x, y+1, z-1),
                        get(x+1, y+1, z-1),
                        get(x-1, y+1, z-1),
                        get(x+1, y-1, z-1),
                        get(x-1, y, z-1),
                        get(x+1, y, z-1),
                        // Sides
                        get(x-1, y-1, z),
                        get(x, y-1, z),
                        get(x, y+1, z),
                        get(x+1, y+1, z),
                        get(x-1, y+1, z),
                        get(x+1, y-1, z),
                        get(x-1, y, z),
                        get(x+1, y, z),
                        // Top
                        get(x-1, y-1, z+1),
                        get(x, y-1, z+1),
                        get(x, y, z+1),
                        get(x, y+1, z+1),
                        get(x+1, y+1, z+1),
                        get(x-1, y+1, z+1),
                        get(x+1, y-1, z+1),
                        get(x-1, y, z+1),
                        get(x+1, y, z+1),
                        ]
                    
                    let neighborsSum = neighbors.compactMap { $0 }.map{ $0 ? 1 : 0 }.reduce(0,+)
                    switch neighborsSum {
                    case 0 ... 3:
                        row.append(false)
                    case 4 ... 6:
                        if let isAlive = get(x, y, z) {
                            if isAlive {
                                row.append(true)
                            } else {
                                row.append(neighborsSum == 4)
                            }
                        } else {
                            row.append(false)
                        }
                    default:
                        row.append(false)
                    }
                }
                plane.append(row)
            }
            newGen.append(plane)
        }
        life = newGen
        update()
    }
    
    private func get(_ x: Int, _ y: Int, _ z: Int) -> Bool? {
        if x > 0, y > 0, z > 0, x < size, y < size, z < zSize {
            let value = life[x][y][z]
            
            return value
        }
        return nil
        
    }
    
    private func get(_ x: Int, _ y: Int, _ z: Int, from: [[[Bool]]]) -> Bool? {
        if x > 0, y > 0, z > 0, x < from.count, y < from.count, z < from.count {
            let value = from[x][y][z]
            
            return value
        }
        return nil
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
