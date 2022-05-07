//
//  ShakeView.swift
//  friendzone
//
//  Created by Paul Kühnel on 06.05.22.
//

import Foundation
import UIKit

extension UIView {
    
    func shakeIt() {
        let shake = CABasicAnimation(keyPath: "position")
        let xDelta = CGFloat(10)
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        
        let fromPoint = CGPoint(x: self.center.x - xDelta, y: self.center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        
        let toPoint = CGPoint(x: self.center.x + xDelta, y: self.center.y)
        let toValue = NSValue(cgPoint: toPoint)
        
        shake.fromValue = fromValue
        shake.toValue = toValue
        shake.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        self.layer.add(shake, forKey: "position")
    }
    
    func rotate() {
        let rotation: CABasicAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotation.toValue = NSNumber(value: Double.pi * 2)
        rotation.duration = 1
        rotation.isCumulative = true
        rotation.repeatCount = Float.greatestFiniteMagnitude
        self.layer.add(rotation, forKey: "rotationAnimation")
    }
    
    func removeRotation() {
        self.layer.removeAnimation(forKey: "rotationAnimation")
    }
}
