//
//  GameViewController.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/21/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

protocol SceneManagerDelegate {
    func presentMenuScene()
    func presentLevelScene()
    func presentGameSceneFor(level: Int)
}

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
    }

}

extension GameViewController: SceneManagerDelegate {
    //Menu Scene
    func presentMenuScene() {
        let menuScene = MenuScene()
        menuScene.sceneManagerDelegate = self
        present(scene: menuScene)
    }
    //Level Selection Scene
    func presentLevelScene() {
        let levelScene = LevelScene()
        levelScene.sceneManagerDelegate = self
        present(scene: levelScene)
        
    }
    //Level Scene for selected level
    func presentGameSceneFor(level: Int) {
        let sceneName = "GameScene_\(level)"
        if let gameScene = SKScene(fileNamed: sceneName) as? GameScene {
            gameScene.sceneManagerDelegate = self
            gameScene.level = level
            present(scene: gameScene)
        }
    }
    //Scene present 
    func present(scene: SKScene) {
        if let view = self.view as! SKView? {
            scene.scaleMode = .resizeFill
            view.presentScene(scene)
            view.ignoresSiblingOrder = true
        }
    }
}
