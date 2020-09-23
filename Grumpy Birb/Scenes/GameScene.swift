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
    case ready, flying, finished, animating
}

class GameScene: SKScene {
    
    var mapNode = SKTileMapNode()
    
    let gameCamera = GameCamera()
    var panRecognizer = UIPanGestureRecognizer()
    var pinchRecognizer = UIPinchGestureRecognizer()
    var maxScale: CGFloat = 0
    
    var birb = Birb(type: .red)
    var birbs =  [
        Birb(type: .blue),
        Birb(type: .yellow),
        Birb(type: .red)
        
    ]
    
    let anchor = SKNode()
    
    var roundState = RoundState.ready
    
    override func didMove(to view: SKView) {
        setupLevel()
        setupGestureRecognizers()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
            let moveCameraBackAction = SKAction.move(to: CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2), duration: 2.0)
            moveCameraBackAction.timingMode = .easeInEaseOut
            gameCamera.run(moveCameraBackAction, completion: {
                self.panRecognizer.isEnabled = true
                self.addBirb()
            })
        case .animating:
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
    
    func setupGestureRecognizers() {
        guard let view = view else { return }
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(pan))
        view.addGestureRecognizer(panRecognizer)
        
        pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinch))
        view.addGestureRecognizer(pinchRecognizer)
    }
    
    func setupLevel() {
        if let mapNode = childNode(withName: "Tile Map Node") as? SKTileMapNode {
            self.mapNode = mapNode
            maxScale = mapNode.mapSize.width/frame.size.width
        }
        
        addCamera()
        
        let physicsRect = CGRect(x: 0, y: mapNode.tileSize.height, width: mapNode.frame.size.width, height: mapNode.frame.size.height - mapNode.tileSize.height)
        physicsBody = SKPhysicsBody(edgeLoopFrom: physicsRect)
        physicsBody?.categoryBitMask = PhysicsCatagory.edge
        physicsBody?.contactTestBitMask = PhysicsCatagory.birb | PhysicsCatagory.block
        physicsBody?.collisionBitMask = PhysicsCatagory.all
        
        anchor.position = CGPoint(x: mapNode.frame.midX/2, y: mapNode.frame.midY/2)
        addChild(anchor)
        addBirb()
    }

    func addCamera() {
        guard let view = view else { return }
        addChild(gameCamera)
        gameCamera.position = CGPoint(x: view.bounds.size.width/2, y: view.bounds.size.height/2)
        camera = gameCamera
        gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
    }
    
    func addBirb() {
        if birbs.isEmpty {
            print("Birbs Gone")
            return
        }
        birb = birbs.removeFirst()
        birb.physicsBody = SKPhysicsBody(rectangleOf: birb.size)
        birb.physicsBody?.categoryBitMask = PhysicsCatagory.birb
        birb.physicsBody?.contactTestBitMask = PhysicsCatagory.all
        birb.physicsBody?.collisionBitMask = PhysicsCatagory.block | PhysicsCatagory.edge
        birb.physicsBody?.isDynamic = false
        birb.position = anchor.position
        addChild(birb)
        constraintToAnchor(active: true)
        roundState = .ready
        
    }
    
    func constraintToAnchor(active: Bool) {
        if active {
            let slingRange = SKRange(lowerLimit: 0.0, upperLimit: birb.size.width*3)
            let positionConstraint = SKConstraint.distance(slingRange, to: anchor)
            birb.constraints = [positionConstraint]
        } else {
            birb.constraints?.removeAll()
        }
    }
    
    override func didSimulatePhysics() {
        guard let physicsBody = birb.physicsBody else { return }
        if roundState == .flying && physicsBody.isResting {
            gameCamera.setConstraints(with: self, and: mapNode.frame, to: nil)
            birb.removeFromParent()
            roundState = .finished
        }
    }
}

extension GameScene {
    
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
