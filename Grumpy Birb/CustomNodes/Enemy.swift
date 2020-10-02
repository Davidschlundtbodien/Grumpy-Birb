//
//  Enemy.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 10/2/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit


enum EnemyType: String {
    case orange
}
    
class Enemy: SKSpriteNode {
        
    let type: EnemyType
    var health: Int
    let animatioinFrames: [SKTexture]
        
    init(type: EnemyType) {
        self.type = type
        animatioinFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: type.rawValue), withName: type.rawValue)
        switch type {
            case .orange:
                health = 100
        }
        let texture = SKTexture(imageNamed: type.rawValue + "1")
        super.init(texture: texture, color: UIColor.clear, size: CGSize.zero)
        animateEnemy()
    }
        
    func animateEnemy() {
        run(SKAction.repeatForever(SKAction.animate(with: animatioinFrames, timePerFrame: 0.3, resize: false, restore: true)))
    }
        
    func createPhysicsBody() {
        physicsBody = SKPhysicsBody(rectangleOf: size)
        physicsBody?.isDynamic = true
        physicsBody?.categoryBitMask = PhysicsCatagory.enemy
        physicsBody?.contactTestBitMask = PhysicsCatagory.all
        physicsBody?.collisionBitMask = PhysicsCatagory.all
    }
        
    func impact(with force: Int) -> Bool {
        health -= force
        if health < 1 {
            removeFromParent()
            return true
        }
        return false
    }
        
        
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
}
    

