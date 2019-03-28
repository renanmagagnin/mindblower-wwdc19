//
//  Objective.swift
//  VectorFields
//
//  Created by Renan Magagnin on 20/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Objective: SKSpriteNode {
    
    var isAboutToBlow = false
    
    init(position: CGPoint) {
        let texture = SKTexture(imageNamed: "Head")
        super.init(texture: texture, color: .clear, size: .init(width: Orb.size.width * 3, height: Orb.size.height * 3))
        self.zPosition = ZPosition.Crossbow
        self.position = position
        
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Physics Body
    func setupPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: size.width/3)
        
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.Objective
        body.contactTestBitMask = PhysicsCategory.Orb
        body.collisionBitMask = PhysicsCategory.None
        body.usesPreciseCollisionDetection = false
        self.physicsBody = body
    }
}

