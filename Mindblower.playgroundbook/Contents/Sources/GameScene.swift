//
//  GameScene.swift
//  VectorFields
//
//  Created by Renan Magagnin on 15/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhysicsCategory {
    static let None            : UInt32 = 0
    static let All             : UInt32 = UInt32.max
    static let Orb             : UInt32 = 0b1
    static let Objective       : UInt32 = 0b10
    static let Inverter        : UInt32 = 0b100
    static let Portal          : UInt32 = 0b1000
    static let Background      : UInt32 = 0b10000
}

struct ZPosition {
    static let Background            : CGFloat = 0
    static let SafeArea              : CGFloat = 10
    static let Crossbow              : CGFloat = 20
    static let Portal                : CGFloat = 30
    static let Inverter              : CGFloat = 40
    static let Orb                   : CGFloat = 50
    static let Particle              : CGFloat = 60
}

public class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    var orbsManager: OrbsManager?
    
    var arrows: [SKSpriteNode] = []
    
    var stages: [Stage] = []
    var currentStage = 1 {
        didSet {
            currentStage = max(min(currentStage, stages.count), 0)
        }
    }
    var stage: Stage {
        return stages[currentStage - 1]
    }
    
    var victoryScene: VictoryScene!
    
    private var lastUpdateTime : TimeInterval = 0
    
    public override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        self.physicsWorld.contactDelegate = self
        self.physicsWorld.gravity = .zero
        
        victoryScene = VictoryScene(size: UIScreen.main.bounds.size)
        
        setupPhysicsBody()
        
        let side = size.width * 0.044
        Orb.size = .init(width: side, height: side)
        
        let maxSpeed = size.width * 0.00585 + 3 // ipad pro: (11, 1366) | ipad2018: (9, 1024)
        Orb.maximumSpeed = maxSpeed
    }
    
    public override func sceneDidLoad() {
        super.sceneDidLoad()
        
        self.backgroundColor = .black
        
        orbsManager = OrbsManager(with: self as SKScene)
        
        self.stages = [StageOne(with: self), StageTwo(with: self), StageThree(with: self), StageFour(with: self), StageFive(with: self)]
        
        spawnArrows()
        
        setup()
        
        self.lastUpdateTime = 0
    }
    
    public override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        // Orbs movement
        orbsManager?.moveOrbs(accordingTo: stage)
        
        // Slingshot
        stage.slingshots.forEach { (slingshot) in
            slingshot.updateSlingshot()
        }
        
        self.lastUpdateTime = currentTime
    }
    
    func setupPhysicsBody() {
        let scaleFactor: CGFloat = 1.1
        let width = frame.width * scaleFactor
        let height = frame.height * scaleFactor
        let body = SKPhysicsBody(edgeLoopFrom: CGRect.init(x: -width/2, y: -height/2, width: width, height: height))
        body.categoryBitMask = PhysicsCategory.Background
        body.contactTestBitMask = PhysicsCategory.All
        body.collisionBitMask = PhysicsCategory.None
        body.usesPreciseCollisionDetection = true
        self.physicsBody = body
    }
    
    func nextStage() {
        if currentStage == stages.count {
            endGame()
        } else {
            currentStage += 1
            
            updateArrows()
            
            setup()
        }
    }
    
    func endGame() {
        guard let view = view else { return }
        
        victoryScene.scaleMode = .aspectFit
        victoryScene.anchorPoint = .init(x: 0.5, y: 0.5)
        view.presentScene(victoryScene)
        
        view.ignoresSiblingOrder = true
        
//        view.showsPhysics = true
//        view.showsFPS = true
//        view.showsNodeCount = true
    }
    
}

// MARK: Setup
extension GameScene {
    
    func setup() {
        setupSlingshots()
        setupObjectives()
        setupPortals()
        setupInverters()
    }
    
    func terminate() {
        for child in children {
            
            animateOut(node: child) {
                if child.name != "arrow" {
                    child.removeFromParent()
                }
            }
        }
//
//        removeSlingshots()
//        removeObjectives()
//        removePortals()
//        removeInverters()
    }
    
    // Slingshots
    func setupSlingshots() {
        for slingshot in stage.slingshots {
            addChild(slingshot)
            
            animateIn(node: slingshot)
        }
    }
    
    func removeSlingshots() {
        for slingshot in stage.slingshots {
            slingshot.removeFromParent()
        }
    }
    
    
    // Objectives
    func setupObjectives() {
        for objective in stage.objectives {
            addChild(objective)
            
            animateIn(node: objective)
        }
    }
    
    func removeObjectives() {
        for objective in stage.objectives {
            objective.removeFromParent()
        }
    }
    
    // Portals
    func setupPortals() {
        for portal in stage.portals {
            addChild(portal)
            
            animateIn(node: portal)
        }
    }
    
    func removePortals() {
        for portal in stage.portals {
            portal.removeFromParent()
        }
    }
    
    // Inverters
    func setupInverters() {
        for inverter in stage.inverters {
            addChild(inverter)
            
            animateIn(node: inverter)
        }
    }
    
    func removeInverters() {
        for inverter in stage.inverters {
            inverter.removeFromParent()
        }
    }
    
    func animateIn(node: SKSpriteNode) {
        node.alpha = 0
        
        let numberOfBlinks = Int.random(in: 1...6)
        let finalAlpha: CGFloat = 1
        
        
        var actions: [SKAction] = []
        
        for i in 0..<numberOfBlinks {
            var blink: [SKAction] = []
            var possibleAlphas: [[CGFloat]] = [[finalAlpha, 0], [finalAlpha/2, 0], [finalAlpha, finalAlpha/2]]
            var alphas = possibleAlphas[Int.random(in: 0..<possibleAlphas.count)]
            
            blink.append(.fadeAlpha(to: alphas[0], duration: 0.1))
            blink.append(.fadeAlpha(to: alphas[1], duration: 0.1))
            
            actions += blink
            
            if i % 2 == 0 {
                actions.append(.wait(forDuration: 0.1))
            }
        }
        
        actions.append(.fadeOut(withDuration: 0.05))
        actions.append(.fadeAlpha(to: finalAlpha/2, duration: 0.1))
        actions.append(.fadeAlpha(to: finalAlpha, duration: 0.5))
        
        
        node.run(.sequence(actions))
    }
    
    func animateOut(node: SKNode, completion block: @escaping () -> Void) {
        let fullAlpha = node.alpha
        
        let numberOfBlinks = Int.random(in: 1...5)
        
        var actions: [SKAction] = []
        
        for i in 0..<numberOfBlinks {
            var blink: [SKAction] = []
            var possibleAlphas: [[CGFloat]] = [[0, fullAlpha], [0, fullAlpha/2], [fullAlpha/2, fullAlpha]]
            var alphas = possibleAlphas[Int.random(in: 0..<possibleAlphas.count)]
            
            blink.append(.fadeAlpha(to: alphas[0], duration: 0.05))
            blink.append(.fadeAlpha(to: alphas[1], duration: 0.05))
            
            if i % 2 == 0 {
                actions.append(.wait(forDuration: 0.1))
            }
            
            actions += blink
        }
        
        // Turn all the way on before finally off
        actions.append(.fadeAlpha(to: fullAlpha, duration: 0.05))
        actions.append(.fadeAlpha(to: 0, duration: 0.05))
//        actions.append(.fadeAlpha(to: 0, duration: 0.3))
        
        node.run(.sequence(actions)) {
            block()
        }
    }
    
}

// MARK: Touch
extension GameScene {
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            let location = t.location(in: self)
//            print(location)
            for slingshot in stage.slingshots {
                let distance = (location - slingshot.position).length()
                if distance <= slingshot.touchRadius {
                    slingshot.touchDown(touch: t)
                }
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            for slingshot in stage.slingshots {
                slingshot.touchUp(touch: t)
            }
        }
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            for slingshot in stage.slingshots {
                slingshot.touchUp(touch: t)
            }
        }
    }
    
}

// MARK: - Arrows
extension GameScene {
    
    func spawnArrows() {
        guard let scene = self.scene else { return }
        
        let size = scene.size
        let width = Int(size.width/1.5)
        let height = Int(size.height/1.5)
        
        let step = Int(size.width * 0.02) // 20 in // 1024 x 768
        
        for x in stride(from: -width, to: width, by: step) {
            for y in stride(from: -height, to: height, by: step) {
                spawnArrow(at: .init(x: x, y: y))
            }
        }
    }
    
    func spawnArrow(at point: CGPoint) {
        guard let scene = self.scene else { return }
        
        // Get texture from color property
        let vectorField = stage.vectorField(at: point)
        let texture = vectorField?.color.texture()
        
        let arrow = SKSpriteNode(texture: texture)
        arrow.position = point
        arrow.name = "arrow"
        
        arrow.size = CGSize(width: size.width * 0.0088, height: size.width * 0.0067) // 9x7 in // 1042 x 768
        arrows.append(arrow)
        scene.addChild(arrow)
        
        updateArrow(arrow)
    }
    
    func invertArrows() {
        for arrow in arrows {
            guard let vectorField = stage.vectorField(at: arrow.position) else { continue }
            let vectorFieldColor = (stage.isInverted) ? vectorField.color.inverseColor() : vectorField.color
            let texture = vectorFieldColor.texture()
            arrow.texture = texture
            
            rotate(arrow: arrow)
        }
        
        // Sound effect
        let playExplosionAction = SKAction.playSoundFileNamed("Inverter", waitForCompletion: false)
        run(playExplosionAction)
    }
    
    func rotate(arrow: SKSpriteNode) {
        let point = arrow.position
        
        let currentVelocity = stage.velocity(at: point)
        let angle = currentVelocity.radians()
        
        let rotateAction = SKAction.rotate(toAngle: angle, duration: 0.5)
        arrow.run(rotateAction)
    }
    
    func rotateArrows() {
        for arrow in arrows {
            let point = arrow.position
            let finalAngle = stage.velocity(at: point).radians()
            let rotateAction = SKAction.rotate(toAngle: finalAngle, duration: 0.5)
            arrow.run(rotateAction)
        }
    }
    
    func updateArrows() {
        for arrow in arrows {
            self.updateArrow(arrow)
        }
    }
    
    func updateArrow(_ arrow: SKSpriteNode) {
        let point = arrow.position
        
        // Get texture from color property
        guard let vectorField = stage.vectorField(at: point) else { return }
        let vectorFieldColor = (stage.isInverted) ? vectorField.color.inverseColor() : vectorField.color
        let texture = vectorFieldColor.texture()
        
        arrow.texture = texture
        arrow.zRotation = stage.velocity(at: point).radians()
        
        // Animation
        arrow.alpha = 0
        
        let finalAlpha: CGFloat = vectorField.alpha
        
        let waitAction = SKAction.wait(forDuration: 1)
        let fadeInAction1 = SKAction.fadeAlpha(to: finalAlpha/2, duration: Stage.fadeDuration/4)
        fadeInAction1.timingMode = SKActionTimingMode.easeIn
        let fadeInAction2 = SKAction.fadeAlpha(to: finalAlpha, duration: Stage.fadeDuration * 3/4)
        fadeInAction2.timingMode = SKActionTimingMode.easeIn
        arrow.run(.sequence([waitAction, fadeInAction1, fadeInAction2]))
    }

}

//MARK: SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    
    public func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // First is lower bit mask
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // Handle contact between orbs and objective
        if let orb = firstBody.node as? Orb,
            let objective = secondBody.node as? Objective {
            
            // Make sure to not detect same contact multiple times
            guard !orb.isImmune else { return }
            
            // Activate orb detonation
            orb.activate() {
                self.explosion(at: orb.position)
                self.orbsManager?.remove(orb)
                
                // Only the first orb will make the mind blow
                if objective.isAboutToBlow == false {
                    self.terminate()
                    self.blow(mind: objective)
                    objective.isAboutToBlow = true
                }
            }
            
            // Sound effect
            let playGrenadeStickAction = SKAction.playSoundFileNamed("GrenadeStick", waitForCompletion: true)
            run(playGrenadeStickAction)
            
            // Make objective bounce
            let bounceDuration = 0.15
            objective.run(.sequence([.scale(to: 0.9, duration: bounceDuration/2), .scale(to: 1, duration: bounceDuration/2)]))
            
            // Wait for a while and trigger next stage
            let duration: TimeInterval = 6
            if self.action(forKey: "nextLevel") == nil {
                let waitAction = SKAction.wait(forDuration: duration)
                let nextLevelAction = SKAction.run {
                    self.nextStage()
                }
                self.run(.sequence([waitAction, nextLevelAction]), withKey: "nextLevel")
            }
        }
        
        // Handle contact between orbs and portals
        if let orb = firstBody.node as? Orb,
            let portal = secondBody.node as? Portal {
            
            guard !portal.isRecharging, let destination = portal.destinationPortal else { return }
            
            let newPosition = destination.position + (orb.position - portal.position)
            orb.run(.move(to: newPosition, duration: 0))
            destination.isRecharging = true
            
            // Sound effect
            let playPortalAction = SKAction.playSoundFileNamed("Portal", waitForCompletion: false)
            run(playPortalAction)
        }
        
        // Handle contact between orbs and inverters
        if let orb = firstBody.node as? Orb,
            let inverter = secondBody.node as? Inverter {
            
            let xScale: CGFloat = (inverter.xScale == 1) ? -1 : 1
            inverter.run(.scaleX(to: xScale, duration: 0.5))
            
            stage.isInverted = !stage.isInverted
            
            invertArrows()
        }
        
        // Handle orb leaving screen, should remove it.
        if let orb = firstBody.node as? Orb, secondBody.categoryBitMask == PhysicsCategory.Background {
            orbsManager?.remove(orb)
        }
        
    }
    
}


// MARK: Particles
extension GameScene {
    
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
            let lifetime: TimeInterval = 3
            let waitAction = SKAction.wait(forDuration: lifetime)
            headPiece.run(.sequence([waitAction, .fadeOut(withDuration: 0.1), .removeFromParent()]))
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
            let lifetime: TimeInterval = 3
            let waitAction = SKAction.wait(forDuration: lifetime)
            headPiece.run(.sequence([waitAction, .fadeOut(withDuration: 0.1), .removeFromParent()]))
        }
        
        if let brainWigglesParticleEmitter = SKEmitterNode(fileNamed: "Explosion.sks") {
            brainWigglesParticleEmitter.position = mind.position
            brainWigglesParticleEmitter.particleZPosition = ZPosition.Particle
            brainWigglesParticleEmitter.targetNode = self
            addChild(brainWigglesParticleEmitter)
            
            let waitAction = SKAction.wait(forDuration: 3)
            let fadeOutAction = SKAction.run {
                brainWigglesParticleEmitter.particleAlphaSpeed = -0.5
            }
            brainWigglesParticleEmitter.run(.sequence([waitAction, fadeOutAction, .wait(forDuration: 4), .removeFromParent()]))
        }
        
        // Removal of mind
        mind.removeFromParent()
        
    }
    
}

