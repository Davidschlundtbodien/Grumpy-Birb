//
//  LevelScene.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/28/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit

class LevelScene: SKScene {

    var sceneManagerDelegate: SceneManagerDelegate?
    
    override func didMove(to view: SKView) {
        setupLevelSelection()
    }
    
    func setupLevelSelection() {
        let background = SKSpriteNode(imageNamed: "levelBackground")
        background.position = CGPoint(x: frame.midX, y: frame.midY)
        background.aspectScale(to: frame.size, width: true, multiplier: 1.0)
        background.zPosition = ZPositions.background
        addChild(background)
        
        
        var level = 1
        let columnStartingPoint = frame.midX/2
        let rowStartingPoint = frame.midY + frame.midY/2
        for row in 0..<3 {
            for column in 0..<3 {
                let levelBoxButton = SpriteKitButton(defaultButtonImage: "woodButton", action: goToGameSceneFor, index: level)
                levelBoxButton.position = CGPoint(x: columnStartingPoint + CGFloat(column) * columnStartingPoint, y: rowStartingPoint - CGFloat(row) * frame.midY/2)
                levelBoxButton.zPosition = ZPositions.hudBackground
                addChild(levelBoxButton)
                
                let levelLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
                levelLabel.fontSize = 200.0
                levelLabel.verticalAlignmentMode = .center
                levelLabel.text = "\(level)"
                levelLabel.aspectScale(to: levelBoxButton.size, width: false, multiplier: 0.5)
                levelLabel.zPosition = ZPositions.hudLabel
                levelBoxButton.addChild(levelLabel)
                
                levelBoxButton.aspectScale(to: frame.size, width: false, multiplier: 0.2)
                
                level += 1
                
            }
        }
        
    }
    
    func goToGameSceneFor(level: Int) {
        sceneManagerDelegate?.presentGameSceneFor(level: level)
    }
    
}
