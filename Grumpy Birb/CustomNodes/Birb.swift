//
//  Birb.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/22/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit

enum BirbType: String {
    case rot, blue, yellow, gray
}

class Birb: SKSpriteNode {
    
    var birbType: BirbType
    var grabbed = false
    //Flying state
    var flying = false {
        didSet {
            if flying {
                physicsBody?.isDynamic = true
                animateFlight(active: true)
            } else {
                animateFlight(active: false)
            }
        }
    }
    
    //Flying animation array
    let flyingFrames: [SKTexture]
    
    init(type:BirbType) {
        birbType = type
        flyingFrames = AnimationHelper.loadTextures(from: SKTextureAtlas(named: type.rawValue), withName: type.rawValue)
        let texture = SKTexture(imageNamed: type.rawValue + "1")

        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 40.0, height: 40.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //Flight animation
    func animateFlight(active: Bool) {
        if active {
            run(SKAction.repeatForever(SKAction.animate(with: flyingFrames, timePerFrame: 0.1, resize: false, restore: true)))
        } else {
            removeAllActions()
        }
    }
}
