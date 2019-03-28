//
//  StageOne.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class StageFour: Stage {
    
    public override func setupSlingshots() {
        guard let scene = self.scene, let orbsManager = (scene as? GameScene)?.orbsManager else { return }
        
//        let slingshotPosition = CGPoint(x: scene.size.width/3, y: -scene.size.height/3)
        
//        let slingshotPosition = CGPoint(x: 0, y: -scene.size.height/2.4)
        let slingshotPosition = CGPoint(x: scene.size.width/3, y: 0)
        
        let slingshot = Slingshot(orbsManager: orbsManager)
        slingshot.position = slingshotPosition
        
        slingshots = [slingshot]
    }
    
    public override func setupObjectives() {
        guard let scene = self.scene else { return }
        
        let objectivePosition = CGPoint(x: -scene.size.width/11, y: 0)
        
        let objective = Objective(position: objectivePosition)
        objectives = [objective]
    }
    
    public override func setupPortals() {
        guard let scene = self.scene else { return }
        
//        let portal1Position = CGPoint(x: 0, y: -scene.size.height/2.4)
        
//        let portal1Position = CGPoint(x: -scene.size.width/3, y: 0)
        let portal1Position = CGPoint(x: 0, y: -scene.size.height/2.4)
        
        let portal2Position = CGPoint(x: scene.size.width/11, y: 0)
        
        let portal1 = Portal(position: portal1Position)
        let portal2 = Portal(position: portal2Position, destinationPortal: portal1)
        
        portal1.destinationPortal = portal2
        
        portals = [portal1, portal2]
    }
    
    public override func setupVectorFields() {
        guard let scene = self.scene else { return }
        
        let obstacleEquation: (CGPoint) -> CGPoint = { point in
            let x = point.x, y = point.y
            return CGPoint(x: x, y: y)
            //            return CGPoint(x: -y/(x*x + y*y), y: x/(x*x + y*y))
        }
        
//        let field = Field(origin: .zero, format: .circularRing(outerRadius: 200, innerRadius: 145))
        let field = Field(origin: .zero, format: .circularRing(outerRadius: scene.size.height/3, innerRadius: scene.size.height/4))
        let vectorField1 = VectorField(equation: obstacleEquation, field: field)
        vectorField1.strength = 155
        vectorField1.color = .red
        
        
        // Background Vector Field
        let backgroundEquation: (CGPoint) -> CGPoint = { point in
            // between 515 385
            let x = point.x * 0.0097, y = point.y * 0.013
            
            let vortex = CGPoint(x: 3 * -y, y: 2*x-2*y)
            let vortexX = vortex.x, vortexY = vortex.y
            
            let sin: CGFloat = sqrt(2)/2
            
            let h = (vortexX * sin) + (vortexY * -sin)
            let v = (vortexX * sin) + (vortexY * sin)
            
//            let sin90: CGFloat = 1
//            let cos90: CGFloat = 0
//
//            let h2 = (h * cos90) + (v * sin90)
//            let v2 = (h * -sin90) + (v * cos90)
            return CGPoint(x: h, y: v)
        }
        
        let backgroundFieldSize = CGSize.init(width: scene.size.width, height: scene.size.height)
        let backgroundField = Field(origin: .init(x: -scene.size.width/2, y: -scene.size.height/2), format: .rectangle(size: backgroundFieldSize))
        let backgroundVectorField = VectorField(equation: backgroundEquation, field: backgroundField)
        backgroundVectorField.strength = 7.5
        backgroundVectorField.alpha = 0.4
        backgroundVectorField.color = .green
        
        
        vectorFields = [vectorField1, backgroundVectorField]
    }
    
}
