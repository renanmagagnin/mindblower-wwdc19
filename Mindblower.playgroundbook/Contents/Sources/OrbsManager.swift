//
//  OrbsManager.swift
//  VectorFields
//
//  Created by Renan Magagnin on 15/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class OrbsManager {
    
    weak var scene: SKScene?
    
    var orbs: [Orb] = []
    
    init(with scene: SKScene) {
        self.scene = scene
    }
    
    func moveOrbs(accordingTo stage: Stage) {
        for orb in orbs {
            
            // Make the vector field affect the orb. (unless it's immune)
            if !orb.isImmune {
                let fieldVelocity = stage.velocity(at: orb.position)
                let velocity = fieldVelocity.normalized() * stage.strength(at: orb.position)/20
                if fieldVelocity != .zero {
                    orb.velocity += velocity
                }
            }
            
            orb.position = orb.position + orb.velocity
        }
    }
}

// MARK: - Orb Spawning/Removing
extension OrbsManager {
    func spawnOrbs() {
        guard let scene = scene else { return }
        
        let size = scene.size
        let width = Int(size.width/1.5)
        let height = Int(size.height/1.5)
        
        let step = 30
        
        for x in stride(from: -width, to: width, by: step) {
            for y in stride(from: -height, to: height, by: step) {
                spawnOrb(at: .init(x: x, y: y))
            }
        }
    }
    
    func spawnOrb(at point: CGPoint, withDirection direction: CGPoint = .zero) -> Orb? {
        guard let scene = scene else { return nil }
        
        let x = point.x / 75.0
        let y = point.y / 56.0
        
        // Create new orb
        let orb = Orb(direction: direction)
        orb.position = point
        scene.addChild(orb)
        orbs.append(orb)
        
        return orb
    }
    
    func remove(_ orb: Orb) {
//        let duration = TimeInterval.random(in: 0.2...0.4)
        let duration = TimeInterval(0)
        
        let fadeOutAction = SKAction.fadeOut(withDuration: duration)
        let scaleAction = SKAction.scale(to: CGFloat(0.0), duration: duration)
        let group = SKAction.group([fadeOutAction, scaleAction])
        
        let removeAction = SKAction.run {
            if let index = self.orbs.firstIndex(of: orb) {
                self.orbs.remove(at: index)
            }
        }
        
        orb.run(.sequence([group, .removeFromParent(), removeAction]))
    }
}
