//
//  Extensions.swift
//  VectorFields
//
//  Created by Renan Magagnin on 15/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import SpriteKit

// MARK: - CGPoint
extension CGPoint {
    
    func radians() -> CGFloat {
        return atan2(self.y, self.x)
    }
    
    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }
    
    func distance(to point: CGPoint) -> CGFloat {
        let distance = (self - point).length()
        return distance
    }
    
    func normalized() -> CGPoint {
        return self / self.length()
    }
    
    func perpendicularClockwise() -> CGPoint {
        return CGPoint(x: -self.y, y: self.x)
    }
    
    func perpendicularCounterClockwise() -> CGPoint {
        return CGPoint(x: self.y, y: -self.x)
    }
    
    // Operations between CGPoint and CGPoint
    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }
    
    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }
    
    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }
    
    static func == (left: CGPoint, right: CGPoint) -> Bool {
        return left.x == right.x && left.y == right.y
    }
    
    // Operations between CGPoint and CGFloat
    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }
    
    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }
    
    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
    
    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }
}
