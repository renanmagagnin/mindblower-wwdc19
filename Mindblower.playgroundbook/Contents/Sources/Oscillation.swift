//
//  Oscillation.swift
//  VectorFields
//
//  Created by Renan Magagnin on 17/03/19.
//  Copyright © 2019 Renan Magagnin. All rights reserved.
//

import UIKit

public class Oscillation {
    var equations: [(CGPoint) -> CGPoint]
    var interval: TimeInterval
    
    private var currentIndex: Int = 0
    var currentEquation: ((CGPoint) -> CGPoint)? {
        guard !equations.isEmpty else { return nil }
        return equations[currentIndex]
    }
    
    init(equations: [(CGPoint) -> CGPoint], interval: TimeInterval) {
        self.equations = equations
        self.interval = interval
    }
    
    // Returns the next equation or nil if the list is empty
    func nextEquation() -> ((CGPoint) -> CGPoint)? {
        var nextIndex = self.currentIndex + 1
        
        if nextIndex >= equations.count || nextIndex < 0 {
            nextIndex = 0
        }
        
        return currentEquation
    }
}
