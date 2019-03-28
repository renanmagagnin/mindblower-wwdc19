//
//  Portals.swift
//  VectorFields
//
//  Created by Renan Magagnin on 20/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Portal: SKSpriteNode {
    
    static let texture = SKTexture(imageNamed: "Portal")
    static let rechargeInterval: TimeInterval = 2     // Interval applied to orbs
    
    var destinationPortal: Portal? = nil
    
    var isRecharging = false {
        didSet {
            guard self.isRecharging == true else { return }
            self.run(.wait(forDuration: Portal.rechargeInterval)) {
                self.isRecharging = false
            }
        }
    }
    
    init(position: CGPoint, destinationPortal: Portal? = nil) {
        let size = CGSize(width: Orb.size.width * 1.43, height: Orb.size.width * 2.13)
        super.init(texture: Portal.texture, color: .clear, size: .init(width: size.width, height: size.height)) // 64.2x96 in 1024x768
        self.zPosition = ZPosition.Portal
        self.destinationPortal = destinationPortal
        self.position = position
        
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Portal {
    
    //MARK: Physics Body
    func setupPhysicsBody() {
        // 733x996 following multipliers are to ignore shadows. without shadows = 535x800
        let body = SKPhysicsBody(rectangleOf: .init(width: size.width * 535/733, height: size.height * 800/996))
        
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.Portal
        body.contactTestBitMask = PhysicsCategory.Orb
        body.collisionBitMask = PhysicsCategory.None
        body.usesPreciseCollisionDetection = true
        self.physicsBody = body
    }
    
}
