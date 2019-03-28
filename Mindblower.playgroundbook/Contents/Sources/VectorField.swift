//
//  VectorField.swift
//  VectorFields
//
//  Created by Renan Magagnin on 15/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

enum VectorColor {
    case white
    case red, green     // Bad vs good
    case orange, blue   // Secondary
    case pink           // Key to success
    
    func texture() -> SKTexture {
        switch self {
        case .white:
            return SKTexture(imageNamed: "WhiteArrow")
        case .orange:
            return SKTexture(imageNamed: "OrangeArrow")
        case .red:
            return SKTexture(imageNamed: "RedArrow")
        case .green:
            return SKTexture(imageNamed: "GreenArrow")
        case .pink:
            return SKTexture(imageNamed: "PinkArrow")
        case .blue:
            return SKTexture(imageNamed: "BlueArrow")
        }
    }
    
    func inverseColor() -> VectorColor {
        switch self {
        case .white:
            return .white
        case .pink:
            return .pink
        case .orange:
            return .blue
        case .blue:
            return .orange
        case .red:
            return .green
        case .green:
            return .red
        }
    }
}

enum FieldFormat {
    case rectangle(size: CGSize)
    case circle(radius: CGFloat)
    case circularRing(outerRadius: CGFloat, innerRadius: CGFloat)
    case ellipse(size: CGSize, radius: CGFloat)
}

public struct Field {
    var origin: CGPoint
    var format: FieldFormat
    
    func contains(point: CGPoint) -> Bool {
        switch format {
        case .rectangle(let size):
            return CGRect(origin: origin, size: .init(width: size.width, height: size.height)).contains(point)
        case .circle(let radius):
            let distance = (origin - point).length()
            return (distance <= radius)
        case .ellipse(let size, let radius):
            let a = size.width/2
            let b = size.height/2
            return ((point.x - origin.x)/a + (point.y - origin.y)/b) <= (radius * radius)
        case .circularRing(let outerRadius, let innerRadius):
            let distance = (origin - point).length()
            return (distance <= outerRadius && distance >= innerRadius)
        }
    }
}

public class VectorField {
    
    // Position in the scene (middle)
    // Area (different shapes: rect, ellipse or circle) SHOULD INCLUDE CONTAINS WITH POLYMORPHISM
    var field: Field!
    
    // Velocity Equation
    var velocity: ((CGPoint) -> CGPoint)!
    
    // Particularities
    var color: VectorColor = .white
    var strength: CGFloat = 1
//    var isInverted = false
    var oscillation: Oscillation?
    
    var alpha: CGFloat = 1
    
    
    init(equation: @escaping (CGPoint) -> CGPoint, field: Field) {
        self.velocity = equation
        self.field = field
    }
    
    // Used to track oscillations
    func update(deltaTime: TimeInterval) {
        
    }
}
