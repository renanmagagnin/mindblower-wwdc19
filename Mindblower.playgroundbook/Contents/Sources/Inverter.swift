//
//  Inverter.swift
//  VectorFields
//
//  Created by Renan Magagnin on 20/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Inverter: SKSpriteNode {
    
    static let texture = SKTexture(imageNamed: "Inverter")
    
    init(position: CGPoint) {
        let side = Orb.size.width * 1.6
        super.init(texture: Inverter.texture, color: .clear, size: .init(width: side, height: side))
        self.zPosition = ZPosition.Inverter
        self.position = position
        
        setupPhysicsBody()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Inverter {
    
    //MARK: Physics Body
    func setupPhysicsBody() {
        let body = SKPhysicsBody(circleOfRadius: size.width/2)
        
        body.isDynamic = true
        body.categoryBitMask = PhysicsCategory.Inverter
        body.contactTestBitMask = PhysicsCategory.Orb
        body.collisionBitMask = PhysicsCategory.None
        body.usesPreciseCollisionDetection = true
        self.physicsBody = body
    }
    
}
