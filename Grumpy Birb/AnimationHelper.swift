//
//  AnimationHelper.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/30/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit

// Animation helper for birb frames 1-4 in assets
class AnimationHelper {
    static func loadTextures(from atlas:SKTextureAtlas, withName name: String) -> [SKTexture] {
        var textures = [SKTexture]()
        
        for index in 0..<atlas.textureNames.count {
            let textureName = name + String(index+1)
            textures.append(atlas.textureNamed(textureName))
        }
        
        
        return textures
    }
}
