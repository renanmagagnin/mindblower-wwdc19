//
//  StageOne.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class StageThree: Stage {
    
    public override func setupSlingshots() {
        guard let scene = self.scene, let orbsManager = (scene as? GameScene)?.orbsManager else { return }
        
        let slingshotPosition = CGPoint(x: -scene.size.width/3.8, y: 0)
        
        let slingshot = Slingshot(orbsManager: orbsManager)
        slingshot.position = slingshotPosition
        
        slingshots = [slingshot]
    }
    
    public override func setupObjectives() {
        guard let scene = self.scene else { return }
        
        let objectivePosition = CGPoint(x: scene.size.width/3.8, y: 0)
        
        let objective = Objective(position: objectivePosition)
        objectives = [objective]
    }
    
    public override func setupInverters() {
        guard let scene = self.scene else { return }
        
        let inverterPosition = CGPoint(x: 0, y: scene.size.height/2.8)
        let inverter = Inverter(position: inverterPosition)
        
        inverters = [inverter]
    }
    
    public override func setupVectorFields() {
        guard let scene = self.scene else { return }
        
        let obstacleEquation: (CGPoint) -> CGPoint = { point in
            return CGPoint(x: -abs(point.x), y: 0)
        }
        
        let obstacleSize = CGSize(width: scene.size.width * 0.14, height: scene.size.height/2)
        
        let field = Field(origin: .init(x: -obstacleSize.width * 1.05, y: 0), format: .rectangle(size: obstacleSize))
        let vectorField1 = VectorField(equation: obstacleEquation, field: field)
        vectorField1.strength = 10
        vectorField1.color = .red
        
        let field3 = Field(origin: .init(x: obstacleSize.width, y: -obstacleSize.height), format: .rectangle(size: obstacleSize))
        let vectorField2 = VectorField(equation: obstacleEquation, field: field3)
        vectorField2.strength = 10
        vectorField2.color = .red
        
        // Background Vector Field
        let backgroundEquation: (CGPoint) -> CGPoint = { point in
            // between 375 and 275
            // between 515 385
            let x = point.x * 0.007, y = point.y * 0.013
            return CGPoint(x: x*x - y*y - 4, y: 2*x*y)
        }
        let backgroundFieldSize = CGSize.init(width: scene.size.width/2, height: scene.size.height)
        
        let backgroundFieldLeft = Field(origin: .init(x: -scene.size.width/2, y: -scene.size.height/2), format: .rectangle(size: backgroundFieldSize))
        let backgroundVectorField = VectorField(equation: backgroundEquation, field: backgroundFieldLeft)
        backgroundVectorField.strength = 2
        backgroundVectorField.alpha = 0.6
        backgroundVectorField.color = .green
        
        let backgroundFieldRight = Field(origin: .init(x: 0, y: -scene.size.height/2), format: .rectangle(size: backgroundFieldSize))
        let backgroundVectorFieldRight = VectorField(equation: backgroundEquation, field: backgroundFieldRight)
        backgroundVectorFieldRight.strength = 2
        backgroundVectorFieldRight.alpha = 0.6
        backgroundVectorFieldRight.color = .red
        
        
        vectorFields = [backgroundVectorField, backgroundVectorFieldRight]
    }

}
