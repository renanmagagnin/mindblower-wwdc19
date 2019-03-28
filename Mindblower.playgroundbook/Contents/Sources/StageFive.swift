//
//  StageOne.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class StageFive: Stage {
    
    public override func setupSlingshots() {
        guard let scene = self.scene, let orbsManager = (scene as? GameScene)?.orbsManager else { return }
        
        let slingshotPosition = CGPoint(x: scene.size.width/3, y: scene.size.height/4)
        
        let slingshot = Slingshot(orbsManager: orbsManager)
        slingshot.position = slingshotPosition
        
        slingshots = [slingshot]
    }
    
    public override func setupObjectives() {
        guard let scene = self.scene else { return }
        
        let objectivePosition = CGPoint(x: scene.size.width/3, y: -scene.size.height/3)
        
        let objective = Objective(position: objectivePosition)
        objectives = [objective]
    }
    
    public override func setupInverters() {
        guard let scene = self.scene else { return }
        
        let inverterPosition = CGPoint.init(x: -scene.size.width/3, y: -scene.size.height/3)
        let inverter = Inverter(position: inverterPosition)
        
        inverters = [inverter]
    }
    
    public override func setupPortals() {
        guard let scene = self.scene else { return }
        
        let portal1Position = CGPoint(x: -scene.size.width/3, y: scene.size.height/2.8)
        let portal2Position = CGPoint(x: -scene.size.width/15, y: -scene.size.height/3)
        
        let portal1 = Portal(position: portal1Position)
        let portal2 = Portal(position: portal2Position, destinationPortal: portal1)
        
        portal1.destinationPortal = portal2
        
        portals = [portal1, portal2]
    }

    public override func setupVectorFields() {
        guard let scene = self.scene else { return }
        
        // Top rectangle
        let obstacleEquation: (CGPoint) -> CGPoint = { point in
            let x = point.x//, y = point.y
            return CGPoint(x: abs(x), y: 0)
        }
        
        let obstacleSize = CGSize(width: scene.size.width/10, height: scene.size.height/2)
        
        let field = Field(origin: .init(x: 0, y: obstacleSize.height/4.5), format: .rectangle(size: obstacleSize))
        let vectorField1 = VectorField(equation: obstacleEquation, field: field)
        vectorField1.strength = 10
        vectorField1.color = .orange
        
        
        let obstacle2Equation: (CGPoint) -> CGPoint = { point in
            let x = point.x//, y = point.y
            return CGPoint(x: -abs(x), y: 0)
        }
        let field6 = Field(origin: .init(x: -obstacleSize.width, y: obstacleSize.height/5), format: .rectangle(size: obstacleSize))
        let vectorField6 = VectorField(equation: obstacle2Equation, field: field6)
        vectorField6.strength = 10
        vectorField6.color = .pink
        
        
        // Horizontal up
        let obstacleEquation2: (CGPoint) -> CGPoint = { point in
            let _ = point.x, y = point.y
            return CGPoint(x: 0, y: abs(y))
        }
        
        let obstacleSize2 = CGSize(width: scene.size.height/1.3, height: scene.size.height/15)
        let field2 = Field(origin: .init(x: -obstacleSize2.width/2, y: -obstacleSize2.height * 2), format: .rectangle(size: obstacleSize2))
        let vectorField2 = VectorField(equation: obstacleEquation2, field: field2)
        vectorField2.strength = 15
        vectorField2.color = .pink
        
        // Horizontal down
        let obstacleEquation3: (CGPoint) -> CGPoint = { point in
            let _ = point.x, y = point.y
            return CGPoint(x: 0, y: -abs(y))
        }
        let field5 = Field(origin: .init(x: field2.origin.x, y: field2.origin.y - obstacleSize2.height), format: .rectangle(size: obstacleSize2))
        let vectorField5 = VectorField(equation: obstacleEquation3, field: field5)
        vectorField5.strength = 15
        vectorField5.color = .orange
        
        
        
        // Pulling
        let pullingPoint = CGPoint.init(x: -scene.size.width/3, y: -scene.size.height/3)
        let pullingEquation: (CGPoint) -> CGPoint = { point in
            let x = point.x, y = point.y
            return CGPoint(x: -(x-pullingPoint.x), y: -(y-pullingPoint.y))
        }
        let smallRadius = scene.size.height/6
        let field3 = Field(origin: pullingPoint, format: .circle(radius: smallRadius))
        let vectorField3 = VectorField(equation: pullingEquation, field: field3)
        vectorField3.strength = 10
        vectorField3.color = .green
        
        
        // Pushing
        let pushingPoint = CGPoint(x: scene.size.width/3, y: -scene.size.height/3)
        let pushingEquation: (CGPoint) -> CGPoint = { point in
            let x = point.x, y = point.y
            return CGPoint(x: x-pushingPoint.x, y: y-pushingPoint.y)
        }
        let radius = scene.size.height/4
        let field4 = Field(origin: pushingPoint, format: .circle(radius: radius))
        let vectorField4 = VectorField(equation: pushingEquation, field: field4)
        vectorField4.strength = 15
        vectorField4.color = .red
        
        
        // Background Vector Field
        let backgroundEquation: (CGPoint) -> CGPoint = { point in
            let x = point.x//, y = point.y
            return .init(x: abs(x), y: 0)
        }
        
        let backgroundFieldSize = CGSize.init(width: scene.size.width, height: scene.size.height)
        let backgroundField = Field(origin: .init(x: -scene.size.width/2, y: -scene.size.height/2), format: .rectangle(size: backgroundFieldSize))
        let backgroundVectorField = VectorField(equation: backgroundEquation, field: backgroundField)
        backgroundVectorField.strength = 1
        backgroundVectorField.alpha = 0.3
        backgroundVectorField.color = .blue
        
        vectorFields = [vectorField1, vectorField2, vectorField3, vectorField4, vectorField5, vectorField6, backgroundVectorField]
    }
    
}
