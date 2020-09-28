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
    var flying = false {
        didSet {
            if flying {
                physicsBody?.isDynamic = true
            }
        }
    }
    
    
    init(type:BirbType) {
        birbType = type
        
        let texture = SKTexture(imageNamed: type.rawValue + "1")

        super.init(texture: texture, color: UIColor.clear, size: CGSize(width: 40.0, height: 40.0))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
