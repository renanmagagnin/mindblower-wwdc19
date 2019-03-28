//
//  Orb.swift
//  VectorFields
//
//  Created by Renan Magagnin on 15/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

enum OrbColor {
    case lightBlue, orange, purple, blue
    
    func texture() -> SKTexture {
        switch self {
        case .lightBlue:
            return SKTexture(imageNamed: "LightBlueBall")
        case .orange:
            return SKTexture(imageNamed: "OrangeBall")
        case .purple:
            return SKTexture(imageNamed: "PurpleBall")
        case .blue:
            return SKTexture(imageNamed: "BlueBall")
        }
    }
    
    static func random(except unwantedColor: OrbColor) -> OrbColor {
        let possibilites: [OrbColor] = [.lightBlue, .orange, .purple, .blue]
        
        var randomIndex = 0
        repeat {
            randomIndex = Int.random(in: 0..<possibilites.count)
        } while possibilites[randomIndex] == unwantedColor
        
        return possibilites[randomIndex]
    }
}

public class Orb: SKSpriteNode {
    
    static var lastColor: OrbColor = .lightBlue
    static var nextColor: OrbColor {
        let nextColor = OrbColor.random(except: lastColor)
        lastColor = nextColor
        return nextColor
    }
    
    static var size: CGSize = CGSize(width: 45, height: 45)
    static var maximumSpeed: CGFloat = 9
    
    var isImmune = false
    
    var velocity: CGPoint = .zero {
        didSet {
            if movementSpeed > Orb.maximumSpeed {
                velocity = velocity.normalized() * Orb.maximumSpeed
            }
        }
    }
    
    var movementSpeed: CGFloat {
        return velocity.length()
    }
    
    var direction: CGPoint {
        return velocity.normalized()
    }
    
    init(direction: CGPoint) {
        let texture = Orb.nextColor.texture()
        super.init(texture: texture, color: .clear, size: Orb.size)
        self.zPosition = ZPosition.Orb
        self.velocity = direction * Orb.maximumSpeed
        
        setupBeep()
        
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func starRotating() {
        let orientation: CGFloat = (Int.random(in: 0...1) == 1) ? 1 : -1
        let degress: CGFloat = CGFloat.random(in: 0...7)
        let rotateAction = SKAction.rotate(toAngle: orientation * (60.0 + degress) * CGFloat.pi, duration: 100)
        run(rotateAction)
    }
    
    func setupBeep() {
        let beep = SKSpriteNode(imageNamed: "Beep")
        beep.size = .init(width: Orb.size.width/2, height: Orb.size.width/1.8)
        beep.name = "beep"
        beep.zPosition = ZPosition.Orb + 1
        beep.position = .init(x: 5, y: 5)
        addChild(beep)
        
        let blinkInAction = SKAction.fadeIn(withDuration: 0.3)
        blinkInAction.timingMode = .easeInEaseOut
        let blinkOutAction = SKAction.fadeOut(withDuration: 0.3)
        blinkOutAction.timingMode = .easeInEaseOut
        let blinkAction = SKAction.repeatForever(.sequence([blinkInAction, blinkOutAction]))
        beep.run(blinkAction, withKey: "blinkAction")
    }
    
    func activate(completion block: @escaping () -> Void) {
        guard let beep = self.childNode(withName: "beep") else { return }
        
        self.velocity = .zero
        self.isImmune = true
        
        // Increase frequency of beep blinking
        let blinkInAction = SKAction.fadeIn(withDuration: 0.07)
        blinkInAction.timingMode = .easeInEaseOut
        let blinkOutAction = SKAction.fadeOut(withDuration: 0.07)
        blinkOutAction.timingMode = .easeInEaseOut
        let blinkAction = SKAction.repeatForever(.sequence([blinkInAction, blinkOutAction]))
        beep.run(blinkAction, withKey: "blinkAction")
        
        // Play sound effect
        let playBeepAction = SKAction.playSoundFileNamed("GrenadeBeep", waitForCompletion: false)
        run(playBeepAction)
        
        // Wait for duration and explode
        let duration: TimeInterval = 1
        run(.wait(forDuration: duration)) {
            block()
        }
    }
    
    //MARK: Physics Body
    func setupPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: size.width * 5/16)
        
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.Orb
        body.contactTestBitMask = PhysicsCategory.Objective | PhysicsCategory.Inverter | PhysicsCategory.Portal | PhysicsCategory.Background
        body.collisionBitMask = PhysicsCategory.None
        body.usesPreciseCollisionDetection = true
        self.physicsBody = body
    }
}
