//
//  Stage.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

public class Stage {
    
    weak var scene: SKScene?
    
    //Position of slingshot
    var slingshots: [Slingshot] = []
    var objectives: [Objective] = []
    
    // List of vector fields(ordered by priority, background last)
    var vectorFields: [VectorField] = []
    
    var isInverted: Bool = false
    
    var portals: [Portal] = []
    
    var inverters: [Inverter] = []
    
    // Animations
    static let fadeDuration: TimeInterval = 1.5
    
    init(with scene: SKScene) {
        self.scene = scene
        
        setupSlingshots()
        setupObjectives()
        setupVectorFields()
        setupPortals()
        setupInverters()
    }
    
    func vectorField(at point: CGPoint) -> VectorField? {
        for vectorField in vectorFields {
            if vectorField.field.contains(point: point) {
                return vectorField
            }
        }
        return nil
    }
    
    func velocity(at point: CGPoint) -> CGPoint {
        guard let vectorField = vectorField(at: point) else { return .zero }
        let inversionMultiplier: CGFloat = (isInverted) ? -1 : 1
        return vectorField.velocity(point) * inversionMultiplier
    }
    
    func strength(at point: CGPoint) -> CGFloat {
        guard let vectorField = vectorField(at: point) else { return 0 }
        return vectorField.strength
    }
    
    // MARK: Setup
    func setupSlingshots() {}
    func setupObjectives() {}
    func setupVectorFields() {}
    func setupPortals() {}
    func setupInverters() {}
}
