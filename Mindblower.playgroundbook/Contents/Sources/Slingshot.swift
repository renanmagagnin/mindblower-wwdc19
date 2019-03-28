//
//  swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Slingshot: SKSpriteNode {
    
    var aimingTouch: UITouch?
    var orb: Orb?
    
    var isReloading = false
    
    // Strips
    var slingshotLeftStrip: SKSpriteNode = SKSpriteNode(imageNamed: "Strip")
    var slingshotRightStrip: SKSpriteNode = SKSpriteNode(imageNamed: "Strip")
    
    var slingshotMaxStretch: CGFloat = 100
    var slingshotMinStretch: CGFloat = 30
    
    weak var orbsManager: OrbsManager!
    
    // Touch
    var touchRadius: CGFloat = 0

    init(orbsManager: OrbsManager) {
        // TODO: Make this work on ipad pro
        let size = CGSize(width: 127.2, height: 49.92)
        let texture = SKTexture(imageNamed: "Crossbow")
        super.init(texture: texture, color: .clear, size: size)
        self.zPosition = ZPosition.Crossbow
        
        self.orbsManager = orbsManager
        
        setupStrips()
        
        touchRadius = size.width * 2
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupStrips() {
        // Left strip
        slingshotLeftStrip.anchorPoint.x = 1
        slingshotLeftStrip.size.height = 10
        slingshotLeftStrip.position.x = -self.size.width/2.3
        slingshotLeftStrip.position.y = -self.size.height/3.7
        slingshotLeftStrip.isHidden = true
        addChild(slingshotLeftStrip)
        
        // Right strip
        slingshotRightStrip.anchorPoint.x = 0
        slingshotRightStrip.size.height = 10
        slingshotRightStrip.position.x = self.size.width/2.3
        slingshotRightStrip.position.y = -self.size.height/3.7
        slingshotRightStrip.isHidden = true
        addChild(slingshotRightStrip)
    }
    
}

extension Slingshot {

    func touchDown(touch: UITouch) {
        guard aimingTouch == nil else { return }

        // If touch is the first touch and near slingshot, register the aiming
        if isReloading == false && aimingTouch == nil {
            aimingTouch = touch

            // Spawn orb
            self.orb = orbsManager?.spawnOrb(at: position, withDirection: .init(x: 1, y: 1))
            orb?.velocity = .zero

            // Show strips
            slingshotLeftStrip.isHidden = false
            slingshotRightStrip.isHidden = false
        }
    }

    func touchUp(touch: UITouch) {
        guard touch == aimingTouch, let slingshotOrb = orb else { return }

        // Calculate direction vector
        let distance = position - slingshotOrb.position
        let direction = distance.normalized()
        let stretch = distance.length()

        // Shoot orb
        let shouldShoot = (stretch >= slingshotMinStretch)

        if shouldShoot {
            let multiplier = stretch / slingshotMaxStretch
            let speed = Orb.maximumSpeed * multiplier
            
            slingshotOrb.velocity = direction * speed
            slingshotOrb.starRotating()
            self.orb?.isImmune = true
            
            // Sound effect
            let playExplosionAction = SKAction.playSoundFileNamed("Crossbow", waitForCompletion: false)
            run(playExplosionAction)
        } else {
            slingshotOrb.removeFromParent()
        }

        self.aimingTouch = nil
        isReloading = true

        let shootingInterval = shouldShoot ? 0.18 : 0

        self.run(.sequence([.wait(forDuration: shootingInterval), .run({
            // Lift immunity
            self.orb?.isImmune = false
            
            // Reset Variables
            self.orb = nil

            // Hide strips
            self.slingshotLeftStrip.isHidden = true
            self.slingshotRightStrip.isHidden = true

            self.isReloading = false
        })]))

    }
}

// MARK: Update
extension Slingshot {
    
    func updateSlingshot() {
        self.updateSlingshotOrb()
        self.updateStrips()
    }
    
    // Given the aimingTouch, update the position of the ball and the slingshot
    func updateSlingshotOrb() {
        guard let aimingTouch = self.aimingTouch,
            let slingshotOrb = self.orb,
            let scene = self.parent else { return }
        
        let point = aimingTouch.location(in: scene)
        
        // Calculate stretch vector
        let stretch = point - position
        let direction = stretch.normalized()
        
        // Calclulate new orb position
        let newLength = min(stretch.length(), slingshotMaxStretch)
        let newOrbPosition = position + (direction * newLength)
        
        slingshotOrb.position = newOrbPosition
        
        // Rotate Slingshot
        zRotation = direction.perpendicularClockwise().radians()
    }
    
    // Given the position of the slingshotOrb, update the strips
    func updateStrips() {
        guard let slingshotOrb = self.orb else { return }
        
        // Calculate stretch vector
        let stretch = slingshotOrb.position - position
        let direction = stretch.normalized()
        
        // Rotate Strips
        let stepDirection = direction.perpendicularClockwise()
        
        let slingshotTangent = position + (stepDirection * size.width/2.3) + (direction * size.height/3.7)
        let orbTangent = slingshotOrb.position + (stepDirection * slingshotOrb.size.width*5/16)
        
        let distance = (orbTangent - slingshotTangent)
        let angle = distance.radians()
        
        slingshotRightStrip.zRotation = angle - zRotation
        
        
        let stepDirectionLeft = direction.perpendicularCounterClockwise()
        
        let slingshotTangentLeft = position + (stepDirectionLeft * size.width/2.3) + (direction * size.height/3.7)
        let orbTangentLeft = slingshotOrb.position + (stepDirectionLeft * slingshotOrb.size.width*5/16)
        
        let distanceLeft = (orbTangentLeft - slingshotTangentLeft) * -1
        let angleLeft = distanceLeft.radians()
        
        slingshotLeftStrip.zRotation = angleLeft - zRotation
        
        // Resize Strips
        let length = distance.length() * 1.12
//        let thickness = length * -0.05 + 7.5
//        slingshotRightStrip.size = CGSize(width: length, height: thickness)
//        slingshotLeftStrip.size = CGSize(width: length, height: thickness)
        slingshotRightStrip.size.width = length
        slingshotLeftStrip.size.width = length
    }
    
}



