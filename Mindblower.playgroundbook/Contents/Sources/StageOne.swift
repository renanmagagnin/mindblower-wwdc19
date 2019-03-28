//
//  StageOne.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class StageOne: Stage {
    
    public override func setupSlingshots() {
        guard let scene = self.scene, let orbsManager = (scene as? GameScene)?.orbsManager else { return }
        
        let slingshotPosition = CGPoint(x: -scene.size.width/3, y: scene.size.height/4)
        
        let slingshot = Slingshot(orbsManager: orbsManager)
        slingshot.position = slingshotPosition
        
        slingshots = [slingshot]
    }
    
    public override func setupObjectives() {
        guard let scene = self.scene else { return }
        
        let objectivePosition = CGPoint(x: scene.size.width/2.8, y: scene.size.height/4)
        
        let objective = Objective(position: objectivePosition)
        objectives = [objective]
    }
    
    public override func setupVectorFields() {
        guard let scene = self.scene else { return }
        
        let equation: (CGPoint) -> CGPoint = { point in
            return CGPoint(x: 0, y: -abs(point.y))
        }
        let radius = scene.size.width/5
        let field = Field(origin: .init(x: radius/4, y: radius), format: .circle(radius: radius))
        let vectorField1 = VectorField(equation: equation, field: field)
        vectorField1.strength = 10
        vectorField1.color = .red
        
        
        // Background Vector Field
        let equation2: (CGPoint) -> CGPoint = { point in
            return CGPoint(x: 0, y: abs(point.y))
        }
        let field2 = Field(origin: .init(x: -scene.size.width/2, y: -scene.size.height/2), format: .rectangle(size: .init(width: scene.size.width, height: scene.size.height)))
        let vectorField2 = VectorField(equation: equation2, field: field2) // background field pointing upwards
        vectorField2.strength = 2
        vectorField2.color = .blue
        vectorField2.alpha = 0.45
        
        vectorFields = [vectorField1, vectorField2]
    }
}
