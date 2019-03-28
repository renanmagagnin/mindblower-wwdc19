//
//  StageOne.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class StageTwo: Stage {

    public override func setupSlingshots() {
        guard let scene = self.scene, let orbsManager = (scene as? GameScene)?.orbsManager else { return }
        
        let slingshotPosition = CGPoint(x: -scene.size.width/3, y: scene.size.height/4)
        
        let slingshot = Slingshot(orbsManager: orbsManager)
        slingshot.position = slingshotPosition
        
        slingshots = [slingshot]
    }
    
    public override func setupObjectives() {
        guard let scene = self.scene else { return }
        
        let objectivePosition = CGPoint(x: scene.size.width/2.6, y: -scene.size.height/4)
        
        let objective = Objective(position: objectivePosition)
        objectives = [objective]
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
        
        let backgroundFieldSize = CGSize.init(width: scene.size.width, height: scene.size.height/2)
        let backgroundEquation: (CGPoint) -> CGPoint = { point in
            return CGPoint(x: 0, y: -point.y)
        }
        
        let bottomBackgroundField = Field(origin: .init(x: -scene.size.width/2, y: -scene.size.height/2), format: .rectangle(size: backgroundFieldSize))
        let topBackgroundField = Field(origin: .init(x: -scene.size.width/2, y: 0), format: .rectangle(size: backgroundFieldSize))
        
        let backgroundVectorField1 = VectorField(equation: backgroundEquation, field: bottomBackgroundField) // background field pointing downwards
        let backgroundVectorField2 = VectorField(equation: backgroundEquation, field: topBackgroundField) // background field pointing upwards
        
        backgroundVectorField1.strength = 4
        backgroundVectorField1.color = .blue
        backgroundVectorField1.alpha = 0.4
        
        backgroundVectorField2.strength = 4
        backgroundVectorField2.color = .pink
        backgroundVectorField2.alpha = 0.4
        
        vectorFields = [vectorField1, vectorField2, backgroundVectorField1, backgroundVectorField2]
    }
}
