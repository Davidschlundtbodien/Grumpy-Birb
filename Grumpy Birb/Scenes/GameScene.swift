//
//  GameScene.swift
//  Grumpy Birb
//
//  Created by David Schlundt-Bodien on 9/21/20.
//  Copyright © 2020 David Schlundt-Bodien. All rights reserved.
//

import SpriteKit
import GameplayKit

enum RoundState {
    case ready, flying, finished, animating, gameOver
}

class GameScene: SKScene {
    
    var sceneManagerDelegate: SceneManagerDelegate?
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0
    
    var birb = Birb(type: .rot)
    var birbs =  [Birb]()
    var enemies = 0 {
        //Checks for remaining enemies
        didSet {
            if enemies < 1 {
                roundState = .gameOver
                presentPopup(victory: true)
            }
        }
    }
    let anchor = SKNode()
    
    var level: Int?
    
    var roundState = RoundState.ready
    
    //On Scene load
    override func didMove(to view: SKView) {
        physicsWorld.contactDelegate = self
        
        guard let level = level else {
            return
        }
        guard let levelData = Level(level: level) else {
            return
        }
        for birbColor in levelData.birbs {
            if let newBirbType = BirbType(rawValue: birbColor) {
                birbs.append(Birb(type: newBirbType))
            }
        }
        
        setupLevel()
        setupGestureRecognizers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Round State
        switch roundState {
        case .ready:
            if let touch = touches.first {
                let location = touch.location(in: self)
                if birb.contains(location) {
                    panRecognizer.isEnabled = false
                    birb.grabbed = true
                    birb.position = location
                }
            }
        case .flying:
            break
        case .finished:
            guard let view = view else { return }
            roundState = .animating
            //Camera Pan back to Birb spawn
            let moveCameraBackAction = SKAction.move(to: CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2), duration: 2.0)
            moveCameraBackAction.timingMode = .easeInEaseOut
            gameCamera.run(moveCameraBackAction, completion: {
                self.panRecognizer.isEnabled = true
                self.addBirb()
            })
        case .animating:
            break
        case .gameOver:
            break
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if birb.grabbed {
                let location = touch.location(in: self)
                birb.position = location
            }
        }
    }
    //Birb release
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if birb.grabbed {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: birb)
            birb.grabbed = false
            birb.flying = true
            roundState = .flying
            constraintToAnchor(active: false)
            let dx = anchor.position.x - birb.position.x
            let dy = anchor.position.y - birb.position.y
            let impulse = CGVector(dx: dx, dy: dy)
            birb.physicsBody?.applyImpulse(impulse)
            birb.isUserInteractionEnabled = false
        }
    }
    
    //Pinch and pan gestures
    func setupGestureRecognizers() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    //Setup Level w/ camera and replace placeholder nodes
    func setupLevel() {
        if let mapNode = childNode(withName: "Tile Map Node") as? SKTileMapNode {
            self.mapNode = mapNode
            maxScale = mapNode.mapSize.width/frame.size.width
        }
        
        addCamera()
        //Replaces blocks and enemy placeholders w/ sk nodes
        for child in mapNode.children {
            if let child = child as? SKSpriteNode {
                guard let name = child.name else { continue }
                switch name {
                    case "wood", "stone", "glass":
                        if let block = createBlock(from: child, name: name) {
                            mapNode.addChild(block)
                            child.removeFromParent()
                        }
                    case "orange":
                        if let enemy = createEnemy(from: child, name: name) {
                            mapNode.addChild(enemy)
                            enemies += 1
                            child.removeFromParent()
                    }
                    default:
                        break
                    
                }

            }
        }
        
        //Border edge physics
        let physicsRect = CGRect(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsRect)
        physicsBody?.categoryBitMask = PhysicsCatagory.edge
        physicsBody?.contactTestBitMask = PhysicsCatagory.birb | PhysicsCatagory.block
        physicsBody?.collisionBitMask = PhysicsCatagory.all
        
        anchor.position = CGPoint(x: mapNode.frame.midX/2, y: mapNode.frame.midY/2)
        addChild(anchor)
        addSlingshot()
        addBirb()
    }
    
    //Camera
    func addCamera() {
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
    }
    
    //Birb Slingshot
    func addSlingshot() {
        let slingshot = SKSpriteNode(imageNamed: "slingshot")
        let scaleSize = CGSize(width: 0, height: mapNode.frame.midY/2)
        slingshot.aspectScale(to: scaleSize, width: false, multiplier: 1.0)
        slingshot.position = CGPoint(x: anchor.position.x, y: mapNode.tileSize.height + slingshot.size.height/2)
        slingshot.zPosition = ZPositions.obstacles
        mapNode.addChild(slingshot)
    }
    
    //Birbs
    func addBirb() {
        if birbs.isEmpty {
            roundState = .gameOver
            presentPopup(victory: false)
            return
        }
        birb = birbs.removeFirst()
        birb.physicsBody = SKPhysicsBody(rectangleOf: birb.size)
        birb.physicsBody?.categoryBitMask = PhysicsCatagory.birb
        birb.physicsBody?.contactTestBitMask = PhysicsCatagory.all
        birb.physicsBody?.collisionBitMask = PhysicsCatagory.block | PhysicsCatagory.edge
        birb.physicsBody?.isDynamic = false
        birb.position = anchor.position
        birb.zPosition = ZPositions.birb
        addChild(birb)
        birb.aspectScale(to: mapNode.tileSize, width: true, multiplier: 1.0)
        constraintToAnchor(active: true)
        roundState = .ready
        
    }
    
    //Blocks
    func createBlock( from placeholder: SKSpriteNode, name: String) -> Block? {
        guard let type = BlockType(rawValue: name) else { return nil }
        let block = Block(type: type)
        block.size = placeholder.size
        block.position = placeholder.position
        block.zRotation = placeholder.zRotation
        block.zPosition = ZPositions.obstacles
        block .createPhysicsBody()
        return block
    }
    
    //Enemies
    func createEnemy(from placeholder: SKSpriteNode, name: String) -> Enemy? {
        guard let enemyType = EnemyType(rawValue: name) else { return nil }
        let enemy = Enemy(type: enemyType)
        enemy.size = placeholder.size
        enemy.position = placeholder.position
        enemy.createPhysicsBody()
        return enemy
    }
        
    //Pull constraints for birbs in slingshot
    func constraintToAnchor(active: Bool) {
        if active {
            let slingRange = SKRange(lowerLimit: 0.0, upperLimit: birb.size.width*3)
            let positionConstraint = SKConstraint.distance(slingRange, to: anchor)
            birb.constraints = [positionConstraint]
        } else {
            birb.constraints?.removeAll()
        }
    }
    
    //Popups
    func presentPopup(victory: Bool) {
        if victory {
            let popup = Popup(type: 0, size: frame.size)
            popup.zPosition = ZPositions.hudBackground
            popup.popupButtonHandlerDelegate = self
            gameCamera.addChild(popup)
        } else {
            let popup = Popup(type: 1, size: frame.size)
            popup.zPosition = ZPositions.hudBackground
            popup.popupButtonHandlerDelegate = self
            gameCamera.addChild(popup)
        }
    }
    
    //After flight
    override func didSimulatePhysics() {
        guard let physicsBody = birb.physicsBody else { return }
        if roundState == .flying && physicsBody.isResting {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            birb.removeFromParent()
            roundState = .finished
        }
    }
}

//Extensions

extension GameScene: PopupButtonHandlerDelegate {
    func menuTapped() {
        sceneManagerDelegate?.presentLevelScene()
    }
    
    func nextTapped() {
        if let level = level {
            sceneManagerDelegate?.presentGameSceneFor(level: level + 1)
        }
    }
    
    func retryTapped() {
        if let level = level {
            sceneManagerDelegate?.presentGameSceneFor(level: level)
        }
    }
}

extension GameScene: SKPhysicsContactDelegate {
    //Physics, contact and collision
    func didBegin(_ contact: SKPhysicsContact) {
        let mask = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
        
        switch mask {
        //Birb vs block and block vs edge
        case PhysicsCatagory.birb | PhysicsCatagory.block, PhysicsCatagory.block | PhysicsCatagory.edge:
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            } else if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let birb = contact.bodyA.node as? Birb {
                birb.flying = false
            } else if let birb = contact.bodyB.node as? Birb {
                birb.flying = false
            }
        //Block vs Block
        case PhysicsCatagory.block | PhysicsCatagory.block:
            if let block = contact.bodyA.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
            if let block = contact.bodyB.node as? Block {
                block.impact(with: Int(contact.collisionImpulse))
            }
        //Birb vs Edge
        case PhysicsCatagory.birb | PhysicsCatagory.edge:
            birb.flying = false
        //Birb vs Enemy
        case PhysicsCatagory.birb | PhysicsCatagory.enemy:
            if let enemy = contact.bodyA.node as? Enemy {
                if enemy.impact(with: Int(contact.collisionImpulse)) {
                    enemies -= 1
                }
            } else if let enemy = contact.bodyB.node as? Enemy {
                if enemy.impact(with: Int(contact.collisionImpulse)) {
                    enemies -= 1
                }
            }
        default:
            break
        }
    }
}

extension GameScene {
    //Pinch and Pan gesture extensions
    @objc func pan(sender: UIPanGestureRecognizer) {
        guard let view = view else { return }
        let translation = sender.translation(in: view) * gameCamera.yScale
        gameCamera.position = CGPoint(x: gameCamera.position.x - translation.x, y: gameCamera.position.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
    }
    
    @objc func pinch(sender: UIPinchGestureRecognizer) {
        guard let view = view else { return }
        if sender.numberOfTouches == 2 {
            let locationInView = sender.location(in: view)
            let location = convertPoint(fromView: locationInView)
            if sender.state == .changed {
                let convertedScale = 1/sender.scale
                let newScale = gameCamera.yScale*convertedScale
                if newScale < maxScale && newScale > 0.5 {
                   gameCamera.setScale(newScale)
                }
                
                let locationAfterScale = convertPoint(toView: locationInView)
                let locationDelta = location - locationAfterScale
                let newPosition = gameCamera.position + locationDelta
                gameCamera.position = newPosition
                sender.scale = 1.0
                gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            }
            
        }
        
    }
    
}
