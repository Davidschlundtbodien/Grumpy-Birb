//
//  Block.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/24/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit

enum BlockType: String {
    case wood, stone, glass
}

class Block: SKSpriteNode {

    let type: BlockType
    var health: Int
    let damageThreshold: Int
    
    init(type: BlockType) {
        //Block health based on type
        self.type = type
        switch type {
        case .wood:
            health = 200
        case .stone:
            health = 500
        case .glass:
            health = 50
        }
        //Threshold for blocks to change texture
        damageThreshold = health/2
        
        let texture = SKTexture(imageNamed: type.rawValue)
        super.init(texture: texture, color: UIColor.clear, size: CGSize.zero )
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Block physics
    func createPhysicsBody () {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCatagory.block
        physicsBody?.contactTestBitMask = PhysicsCatagory.all
        physicsBody?.collisionBitMask = PhysicsCatagory.all
    }
    
    //Block health reduction based on impact
    func impact(with force: Int) {
        health -= force
        print(health)
        if health < 1 {
            removeFromParent()
        } else if health < damageThreshold {
            let brokenTexture = SKTexture(imageNamed: type.rawValue + "Broken")
            texture = brokenTexture
        }
    }
    
}
