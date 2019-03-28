//
//  MenuScene.swift
//  VectorFields
//
//  Created by Renan Magagnin on 20/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class VictoryScene: SKScene {

    var victoryText: SKSpriteNode!
    var additionalText: SKSpriteNode!
    
    // Time after animation is done and before taps are accepted
    var timeBeforeReady = TimeInterval(2)
    var isReady = false
    
    var menuScene: MenuScene!
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.physicsWorld.gravity = .zero
        
        self.backgroundColor = .black
        
        setup()
        
        // Animate in and schedule tap readiness
        animateIn {
            self.run(.wait(forDuration: self.timeBeforeReady)) {
                self.isReady = true
                print("is ready")
            }
        }
        
        // Commence mind spawning
        let spawningInterval: TimeInterval = 1.2
        
        let spawnMindAction = SKAction.run({
            let minX = self.size.width * 0.40
            let minY = self.size.height * 0.35
            
            var randomX: CGFloat = 0
            var randomY: CGFloat = 0
            repeat {
                randomX = CGFloat.random(in: -self.size.width/2...self.size.width/2)
                randomY = CGFloat.random(in: -self.size.height/2...self.size.height/2)
                
            } while abs(randomX) < minX && abs(randomY) < minY
            
            let randomPosition = CGPoint(x: randomX, y: randomY)
            
            self.spawnMind(at: randomPosition)
        })
        
        run(SKAction.repeatForever(.sequence([.wait(forDuration: spawningInterval), spawnMindAction])))
        
        
    }
    
    public override func sceneDidLoad() {
        menuScene = MenuScene(size: UIScreen.main.bounds.size)
    }
    
}

// MARK: Touch
extension VictoryScene {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isReady {
            animateOut {
                self.restartGame()
            }
        }
    }
}


// MARK: Setup
extension VictoryScene {
    func setup() {
        setupAdditionalText()
        setupVictoryText()
    }
    
    func setupVictoryText() {
        let victoryTextSize = CGSize.init(width: size.width * 0.87, height: size.height * 0.35) // 1037x290 in 1194x834
        victoryText = SKSpriteNode(imageNamed: "Congratulations")
        victoryText.size = victoryTextSize
        victoryText.position.y = size.height * 0.055
        victoryText.alpha = 0
        addChild(victoryText)
    }
    
    func setupAdditionalText() {
        let additionalTextSize = CGSize(width: size.width * 0.55, height: size.height * 0.19) // 656x162 in 1194x834
        additionalText = SKSpriteNode(imageNamed: "AdditionalText")
        additionalText.size = additionalTextSize
        additionalText.position.y = -size.height * 0.16
        additionalText.alpha = 0
        addChild(additionalText)
    }

}

// MARK: Animation
extension VictoryScene {
//    func animateIn(completion block: @escaping () -> Void) {
//        let duration: TimeInterval = 0.5
//
//        let fadeInAction = SKAction.fadeIn(withDuration: duration)
//        fadeInAction.timingMode = .easeInEaseOut
//
//        let group = SKAction.group([fadeInAction])
//
//        victoryText.run(fadeInAction) {
//            block()
//        }
//
//        additionalText.run(.sequence([group]))
//    }
    
    func animateIn(completion block: @escaping () -> Void) {
        let duration: TimeInterval = 5
        
        // Logo actions
        let actions = [
            SKAction.fadeAlpha(to: 0.5, duration: duration/30),
            
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 1, duration: duration/50),
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 0.5, duration: duration/50),
            
            .wait(forDuration: 0.2),
            
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 0.5, duration: duration/50),
            SKAction.fadeAlpha(to: 0, duration: duration/50),
            SKAction.fadeAlpha(to: 1, duration: duration/50),
            
            .wait(forDuration: 0.2),
            
            SKAction.fadeAlpha(to: 1, duration: duration/20),
            SKAction.fadeAlpha(to: 0.5, duration: duration/20),
            SKAction.fadeAlpha(to: 1, duration: duration/20),
            SKAction.fadeAlpha(to: 0, duration: duration/20),
            
            SKAction.fadeAlpha(to: 1, duration: 0.5),
            
            SKAction.wait(forDuration: 0.5)
        ]
        
        for action in actions {
            action.timingMode = .easeInEaseOut
        }
        
        // Play victoryText actions and at the end, play additional text actions
        victoryText.run(.sequence(actions)) {
            self.additionalText.run(.sequence(actions))
            block()
        }
        
        // Play static sound
        let playStaticAction = SKAction.playSoundFileNamed("NeonStatic", waitForCompletion: true)
        run(.repeatForever(playStaticAction), withKey: "neonStatic")
        
    }
    
    
    
    func animateOut(completion block: @escaping () -> Void) {
        additionalText.removeAllActions()
        
        let duration = 1.5
        
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        fadeOutAction.timingMode = .easeInEaseOut
        
        victoryText.run(fadeOutAction)
        additionalText.run(fadeOutAction) {
            block()
        }
        
    }
}

// MARK: Navigation
extension VictoryScene {
    
    func restartGame() {
        guard let view = view else { return }
        
        menuScene.scaleMode = .aspectFit
        menuScene.anchorPoint = .init(x: 0.5, y: 0.5)
        view.presentScene(menuScene)
        
        view.ignoresSiblingOrder = true
        
//        view.showsPhysics = true
//        view.showsFPS = true
//        view.showsNodeCount = true
    }
}

// MARK: Spawning
extension VictoryScene {
    
    func spawnMind(at location: CGPoint) {
        let mind = Objective(position: location)
        mind.alpha = 0
        addChild(mind)
        
        let fadeDuration: TimeInterval = 1.5
        mind.run(.fadeAlpha(to: 0.8, duration: fadeDuration))
        
        var lifetime = TimeInterval.random(in: 1...2)
        lifetime += fadeDuration
        
        let blowAction = SKAction.run {
            self.explosion(at: mind.position)
            self.blow(mind: mind)
        }
        self.run(.sequence([.wait(forDuration: lifetime), blowAction]))
    }
    
}

// MARK: Particles
extension VictoryScene {
    
    func explosion(at location: CGPoint) {
        
        // Inner plasma
        if let innerPlasmaParticleEmitter = SKEmitterNode(fileNamed: "InnerPlasma.sks") {
            innerPlasmaParticleEmitter.position = location
            innerPlasmaParticleEmitter.zPosition = ZPosition.Particle
            innerPlasmaParticleEmitter.targetNode = self
            innerPlasmaParticleEmitter.particleScale *= 2
            addChild(innerPlasmaParticleEmitter)
            
            let waitAction = SKAction.wait(forDuration: 1.5)
            innerPlasmaParticleEmitter.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        // Middle plasma
        if let middlePlasmaParticleEmitter = SKEmitterNode(fileNamed: "MiddlePlasma.sks") {
            middlePlasmaParticleEmitter.position = location
            middlePlasmaParticleEmitter.zPosition = ZPosition.Particle
            middlePlasmaParticleEmitter.targetNode = self
            addChild(middlePlasmaParticleEmitter)
            
            let waitAction = SKAction.wait(forDuration: 1.5)
            middlePlasmaParticleEmitter.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        // Outer plasma
        if let outerPlasmaParticleEmitter = SKEmitterNode(fileNamed: "OuterPlasma.sks") {
            outerPlasmaParticleEmitter.position = location
            outerPlasmaParticleEmitter.particleZPosition = ZPosition.Particle
            outerPlasmaParticleEmitter.targetNode = self
            addChild(outerPlasmaParticleEmitter)
            
            let waitAction = SKAction.wait(forDuration: 1.5)
            outerPlasmaParticleEmitter.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        // Sound effect
        let playExplosionAction = SKAction.playSoundFileNamed("GrenadeExplosion", waitForCompletion: false)
        run(playExplosionAction)
        
    }
    
    func blow(mind: Objective) {
        
        let headPieces = 4
        let brainPieces = 5
        let directions: [CGPoint] = [.init(x: 1, y: 1), .init(x: -1, y: -1), .init(x: 1, y: -1), .init(x: -1, y: 1)]
        
        // Head Pieces
        for i in 1...headPieces {
            
            // Spawn head piece
            let sizeDivider: CGFloat = 5
            let imageName = "HeadPiece\(i)"
            let headPiece = SKSpriteNode(imageNamed: imageName)
            headPiece.size = .init(width: headPiece.size.width/sizeDivider, height: headPiece.size.height/sizeDivider)
            headPiece.position = mind.position
            headPiece.zPosition = ZPosition.Inverter
            addChild(headPiece)
            
            // Movement
            let direction = directions[i-1]
            let distance = size.width * 1.1
            let vector = CGVector(dx: direction.x * distance, dy: direction.y * distance)
            let movementDuration: TimeInterval = 6
            headPiece.run(.move(by: vector, duration: movementDuration))
            
            // Rotation
            let rotationPeriod: TimeInterval = 0.5
            let rotateAction = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: rotationPeriod)
            headPiece.run(.repeatForever(rotateAction))
            
            // Removal
            let lifetime: TimeInterval = 5
            let waitAction = SKAction.wait(forDuration: lifetime)
            headPiece.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        // Brain Pieces
        for i in 1...brainPieces {
            
            // Spawn head piece
            let sizeDivider: CGFloat = 5
            let imageName = "BrainPiece\(i)"
            let headPiece = SKSpriteNode(imageNamed: imageName)
            headPiece.size = .init(width: headPiece.size.width/sizeDivider, height: headPiece.size.height/sizeDivider)
            headPiece.position = mind.position
            headPiece.zPosition = ZPosition.Inverter
            addChild(headPiece)
            
            // Movement
            let randomX = CGFloat.random(in: 0...1)
            let randomY = CGFloat.random(in: 0...1)
            let direction = CGPoint(x: randomX, y: randomY)
            let distance = size.width * 1.1
            let vector = CGVector(dx: direction.x * distance, dy: direction.y * distance)
            let movementDuration: TimeInterval = 6
            headPiece.run(.move(by: vector, duration: movementDuration))
            
            // Rotation
            let rotationPeriod: TimeInterval = 0.5
            let rotateAction = SKAction.rotate(byAngle: 2 * CGFloat.pi, duration: rotationPeriod)
            headPiece.run(.repeatForever(rotateAction))
            
            // Removal
            let lifetime: TimeInterval = 5
            let waitAction = SKAction.wait(forDuration: lifetime)
            headPiece.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        if let brainWigglesParticleEmitter = SKEmitterNode(fileNamed: "Explosion.sks") {
            brainWigglesParticleEmitter.position = mind.position
            brainWigglesParticleEmitter.particleZPosition = ZPosition.Particle
            brainWigglesParticleEmitter.targetNode = self
            addChild(brainWigglesParticleEmitter)
            
            let waitAction = SKAction.wait(forDuration: 5)
            brainWigglesParticleEmitter.run(.sequence([waitAction, .removeFromParent()]))
        }
        
        // Removal of mind
        mind.removeFromParent()
        
    }
    
}

