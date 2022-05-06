//
//  LogniViewController.swift
//  friendzone
//
//  Created by Paul Kühnel on 29.04.22.
//  Copyright © 2022 aaa - all about apps Gmbh. All rights reserved.
//

import Foundation
import UIKit
import SwiftUI
import Combine
import SFSafeSymbols
import Toolbox
import ConfettiSwiftUI

class WelcomeViewController: UIViewController {
    
    public static func createWith(storyboard: Storyboard) -> Self {
        let viewController = UIStoryboard(storyboard).instantiateViewController(self)
        return viewController
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
        
    var onLogin: (() -> Void)!
    var onRegister: (() -> Void)!
    var onRegistered: (() -> Void)!
    
    @IBOutlet var confettiView: UIView!
    @IBOutlet var authButtonView: UIView!
    @IBOutlet var welcomeTitleLabel: UILabel!
    @IBOutlet var headerView: UIView!
    @IBOutlet var registerButton: FriendZoneButton!
    @IBOutlet var loginButton: FriendZoneButton!
    @IBOutlet var personImage: UIImageView!
    @IBOutlet var teamImage: UIImageView!
    @IBOutlet var coupleImage: UIImageView!
    @IBOutlet var friendImage: UIImageView!
    @IBOutlet var backgroundView: UIView!
        
    var loggedIn: Bool = false
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
      
    func setupView() {
        confettiView.isHidden = true

        let framer = RectFramer(withView: headerView)
        framer.drawLineIn(withRectRef: framer)
        framer.drawUpperLineIn(withRectRef: framer)

        loginButton.setStyle(.tertiaryDark)
        loginButton.setTitle("Login", for: .normal)
        registerButton.setStyle(.primaryDark)
        registerButton.setTitle("Neues Konto erstellen", for: .normal)
        headerView.layer.cornerRadius = 10
        
        drawLine(startPoint: CGPoint(x: personImage.frame.midX, y: personImage.frame.midY), endPoint: CGPoint(x: friendImage.frame.midX, y: friendImage.frame.midY))
        drawLine(startPoint: CGPoint(x: personImage.frame.midX, y: personImage.frame.midY * 0.9), endPoint: CGPoint(x: coupleImage.frame.midX, y: coupleImage.frame.midY))
        drawLine(startPoint: CGPoint(x: personImage.frame.midX, y: personImage.frame.midY * 0.8), endPoint: CGPoint(x: teamImage.frame.midX, y: teamImage.frame.midY))
    }
    
    var timer: Timer?
    
    func showSuccessfulRegistration() {
        backgroundView.isHidden = true
        authButtonView.isHidden = true
        welcomeTitleLabel.text = "Geschafft!"
        registerButton.setTitle("Los gehts!", for: .normal)
        confettiView.isHidden = false
        loggedIn = true
        if let viewda = UIHostingController.init(rootView: ConfettiView()).view {
        confettiView.addSubview(viewda)
        confettiView.frame = viewda.frame
        }
    }
    
    @IBAction func loginButtonTapped(_ sender: Any) {
        onLogin()
    }
    
    @IBAction func registerTapped(_ sender: Any) {
        if loggedIn {
            onRegistered()
        } else {
            onRegister()
        }
    }
    
    var confettiSwiftUIView = ConfettiView()
    
    func drawLine(startPoint: CGPoint, endPoint: CGPoint) {
        let path = UIBezierPath()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
    
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0).cgColor
        shapeLayer.strokeColor = UIColor.systemGreen.cgColor
        shapeLayer.lineWidth = 4
        shapeLayer.path = path.cgPath
        shapeLayer.lineDashPattern = [3, 3, 3]
                
        backgroundView.layer.insertSublayer(shapeLayer, at: 0)
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.duration = 1
        shapeLayer.add(animation, forKey: "MyAnimation")
    }
}

internal struct RectFramer {
    var viewRef: UIView
    
    let maxY, maxX, midX, midY, minX, minY: CGFloat
    let origin, bottomRight, topRight, bottomLeft, topMid, topLeft, rightMid, topMidCenter: CGPoint
    let smallBottomRight, smallTopLeft: CGPoint
    
    internal init(withView view: UIView) {
        viewRef = view
        
        maxY = view.bounds.maxY
        maxX = view.bounds.maxX
        minX = view.bounds.minX
        minY = view.bounds.minY
        midX = view.bounds.midX
        midY = view.bounds.midY
        origin = CGPoint(x: maxX, y: minY)
        bottomRight = CGPoint(x: maxX, y: midY)
        topRight = origin
        topMid = CGPoint(x: midX, y: minY)
        topLeft = CGPoint(x: midX, y: minY)
        bottomLeft = CGPoint(x: midX, y: midY)
        rightMid = CGPoint(x: maxX - midX / 2, y: midY - midY / 2)
        topMidCenter = CGPoint(x: maxX, y: midY - midY / 2)
        
        smallBottomRight = CGPoint(x: maxX, y: midY / 2)
        smallTopLeft = CGPoint(x: maxX * 0.69, y: minY)
    }
    
    internal func drawUpperLineIn(withRectRef rectRef: RectFramer) {
        let refView = rectRef.viewRef
        
        // wave crest anims
        let bezPathStage0: UIBezierPath = UIBezierPath()
        bezPathStage0.move(to: rectRef.topRight)
        bezPathStage0.addLine(to: rectRef.smallTopLeft)
        bezPathStage0.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: CGPoint(x: rectRef.maxX * 0.7, y: rectRef.minY))
        //        bezPathStage0.addLine(to: rectRef.rightMid)
        bezPathStage0.close()
        
        let bezPathStage1: UIBezierPath = UIBezierPath()
        bezPathStage1.move(to: rectRef.topRight)
        bezPathStage1.addLine(to: rectRef.smallTopLeft)
        bezPathStage1.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.midY))
        //        bezPathStage1.addLine(to: rectRef.rightMid)
        bezPathStage1.close()
        
        let bezPathStage2: UIBezierPath = UIBezierPath()
        bezPathStage2.move(to: rectRef.topRight)
        bezPathStage2.addLine(to: rectRef.smallTopLeft)
        bezPathStage2.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.midY - rectRef.midY / 2))
        //        bezPathStage2.addLine(to: rectRef.rightMid)
        bezPathStage2.close()
        
        let bezPathStage3: UIBezierPath = UIBezierPath()
        bezPathStage3.move(to: rectRef.topRight)
        bezPathStage3.addLine(to: rectRef.smallTopLeft)
        bezPathStage3.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: CGPoint(x: rectRef.midX - rectRef.midX / 2, y: rectRef.midY - rectRef.midY / 2))
        bezPathStage3.close()
        
        let bezPathStage4 = bezPathStage0
        
        let bezPathStage5: UIBezierPath = UIBezierPath()
        bezPathStage5.move(to: rectRef.topRight)
        bezPathStage5.addLine(to: rectRef.smallTopLeft)
        bezPathStage5.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: rectRef.topMidCenter)
        bezPathStage5.close()
        
        let bezPathStage6: UIBezierPath = UIBezierPath()
        bezPathStage6.move(to: rectRef.topRight)
        bezPathStage6.addLine(to: rectRef.smallTopLeft)
        bezPathStage6.addQuadCurve(to: rectRef.smallBottomRight, controlPoint: CGPoint(x: rectRef.midX + rectRef.midX / 2, y: rectRef.midY - rectRef.midY / 2))
        bezPathStage6.close()
        
        let bezPathStage7: UIBezierPath = UIBezierPath()
        bezPathStage7.move(to: rectRef.topRight)
        bezPathStage7.addLine(to: rectRef.topLeft)
        bezPathStage7.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.minY))
        bezPathStage7.close()
        
        let bezPathStage8: UIBezierPath = bezPathStage0
        
        // .. more code    // 1. we want to animate the bezier's drawing path
        let animStage0: CABasicAnimation = CABasicAnimation(keyPath: "path")
        // 2. Start at stage0, go to stage1
        animStage0.fromValue = bezPathStage0.cgPath
        animStage0.toValue = bezPathStage1.cgPath
        // 3. Setting up timing
        animStage0.beginTime = 0.0
        animStage0.duration = 2.5
        
        let animStage1: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage1.fromValue = bezPathStage1.cgPath
        animStage1.toValue = bezPathStage2.cgPath
        animStage1.beginTime = animStage0.beginTime + animStage0.duration // incremental timing
        animStage1.duration =  animStage0.duration
        
        let animStage2: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage2.fromValue = bezPathStage2.cgPath
        animStage2.toValue = bezPathStage3.cgPath
        animStage2.beginTime = animStage1.beginTime + animStage1.duration
        animStage2.duration = animStage0.duration
        
        let animStage3: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage3.fromValue = bezPathStage3.cgPath
        animStage3.toValue = bezPathStage4.cgPath
        animStage3.beginTime = animStage2.beginTime + animStage2.duration
        animStage3.duration = animStage0.duration
        
        let animStage4: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage4.fromValue = bezPathStage4.cgPath
        animStage4.toValue = bezPathStage5.cgPath
        animStage4.beginTime = animStage3.beginTime + animStage3.duration
        animStage4.duration = animStage0.duration
        
        let animStage5: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage5.fromValue = bezPathStage5.cgPath
        animStage5.toValue = bezPathStage6.cgPath
        animStage5.beginTime = animStage4.beginTime + animStage4.duration
        animStage5.duration = animStage0.duration
        
        let animStage6: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage6.fromValue = bezPathStage6.cgPath
        animStage6.toValue = bezPathStage7.cgPath
        animStage6.beginTime = animStage5.beginTime + animStage5.duration
        animStage6.duration = animStage0.duration
        
        let animStage7: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage7.fromValue = bezPathStage7.cgPath
        animStage7.toValue = bezPathStage8.cgPath
        animStage7.beginTime = animStage6.beginTime + animStage6.duration
        animStage7.duration = animStage0.duration
        
        let drawingLayer = CAShapeLayer()
        drawingLayer.path = bezPathStage0.cgPath
        drawingLayer.strokeColor = Asset.loginBlobColor2.color.cgColor
        drawingLayer.fillColor = Asset.loginBlobColor2.color.cgColor
        drawingLayer.lineWidth = 2.0
        
        let waveAnimGroup: CAAnimationGroup = CAAnimationGroup()
        waveAnimGroup.animations = [animStage0, animStage1, animStage2, animStage3, animStage4, animStage5, animStage6, animStage7]
        waveAnimGroup.duration = animStage3.beginTime + animStage3.duration
        waveAnimGroup.fillMode = CAMediaTimingFillMode.forwards
        waveAnimGroup.isRemovedOnCompletion = false
        waveAnimGroup.repeatCount = Float.infinity
        
        drawingLayer.add(waveAnimGroup, forKey: "waveCrest")
        refView.layer.addSublayer(drawingLayer)
        refView.layer.insertSublayer(drawingLayer, at: 1)
    }
    
    internal func drawLineIn(withRectRef rectRef: RectFramer) {
        let refView = rectRef.viewRef
        
        // wave crest anims
        let bezPathStage0: UIBezierPath = UIBezierPath()
        bezPathStage0.move(to: rectRef.topRight)
        bezPathStage0.addLine(to: rectRef.topLeft)
        bezPathStage0.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.minY))
        //        bezPathStage0.addLine(to: rectRef.rightMid)
        bezPathStage0.close()
        
        let bezPathStage1: UIBezierPath = UIBezierPath()
        bezPathStage1.move(to: rectRef.topRight)
        bezPathStage1.addLine(to: rectRef.topLeft)
        bezPathStage1.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.minX, y: rectRef.midY))
        //        bezPathStage1.addLine(to: rectRef.rightMid)
        bezPathStage1.close()
        
        let bezPathStage2: UIBezierPath = UIBezierPath()
        bezPathStage2.move(to: rectRef.topRight)
        bezPathStage2.addLine(to: rectRef.topLeft)
        bezPathStage2.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.midY - rectRef.midY / 2))
        //        bezPathStage2.addLine(to: rectRef.rightMid)
        bezPathStage2.close()
        
        let bezPathStage3: UIBezierPath = UIBezierPath()
        bezPathStage3.move(to: rectRef.topRight)
        bezPathStage3.addLine(to: rectRef.topLeft)
        bezPathStage3.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX - rectRef.midX / 2, y: rectRef.midY - rectRef.midY / 2))
        bezPathStage3.close()
        
        let bezPathStage4 = bezPathStage0
        
        let bezPathStage5: UIBezierPath = UIBezierPath()
        bezPathStage5.move(to: rectRef.topRight)
        bezPathStage5.addLine(to: rectRef.topLeft)
        bezPathStage5.addQuadCurve(to: rectRef.bottomRight, controlPoint: rectRef.topMidCenter)
        bezPathStage5.close()
        
        let bezPathStage6: UIBezierPath = UIBezierPath()
        bezPathStage6.move(to: rectRef.topRight)
        bezPathStage6.addLine(to: rectRef.topLeft)
        bezPathStage6.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.midY - rectRef.midY / 2))
        bezPathStage6.close()
        
        let bezPathStage7: UIBezierPath = UIBezierPath()
        bezPathStage7.move(to: rectRef.topRight)
        bezPathStage7.addLine(to: rectRef.topLeft)
        bezPathStage7.addQuadCurve(to: rectRef.bottomRight, controlPoint: CGPoint(x: rectRef.midX, y: rectRef.minY))
        bezPathStage7.close()
        
        let bezPathStage8: UIBezierPath = bezPathStage0
        
        // .. more code    // 1. we want to animate the bezier's drawing path
        let animStage0: CABasicAnimation = CABasicAnimation(keyPath: "path")
        // 2. Start at stage0, go to stage1
        animStage0.fromValue = bezPathStage0.cgPath
        animStage0.toValue = bezPathStage1.cgPath
        // 3. Setting up timing
        animStage0.beginTime = 0.0
        animStage0.duration = 4.0
        
        let animStage1: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage1.fromValue = bezPathStage1.cgPath
        animStage1.toValue = bezPathStage2.cgPath
        animStage1.beginTime = animStage0.beginTime + animStage0.duration // incremental timing
        animStage1.duration =  animStage0.duration
        
        let animStage2: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage2.fromValue = bezPathStage2.cgPath
        animStage2.toValue = bezPathStage3.cgPath
        animStage2.beginTime = animStage1.beginTime + animStage1.duration
        animStage2.duration = animStage0.duration
        
        let animStage3: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage3.fromValue = bezPathStage3.cgPath
        animStage3.toValue = bezPathStage4.cgPath
        animStage3.beginTime = animStage2.beginTime + animStage2.duration
        animStage3.duration = animStage0.duration
        
        let animStage4: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage4.fromValue = bezPathStage4.cgPath
        animStage4.toValue = bezPathStage5.cgPath
        animStage4.beginTime = animStage3.beginTime + animStage3.duration
        animStage4.duration = animStage0.duration
        
        let animStage5: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage5.fromValue = bezPathStage5.cgPath
        animStage5.toValue = bezPathStage6.cgPath
        animStage5.beginTime = animStage4.beginTime + animStage4.duration
        animStage5.duration = animStage0.duration
        
        let animStage6: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage6.fromValue = bezPathStage6.cgPath
        animStage6.toValue = bezPathStage7.cgPath
        animStage6.beginTime = animStage5.beginTime + animStage5.duration
        animStage6.duration = animStage0.duration
        
        let animStage7: CABasicAnimation = CABasicAnimation(keyPath: "path")
        animStage7.fromValue = bezPathStage7.cgPath
        animStage7.toValue = bezPathStage8.cgPath
        animStage7.beginTime = animStage6.beginTime + animStage6.duration
        animStage7.duration = animStage0.duration
        
        let drawingLayer = CAShapeLayer()
        drawingLayer.path = bezPathStage0.cgPath
        drawingLayer.strokeColor = Asset.loginBlobColor1.color.cgColor
        drawingLayer.fillColor = Asset.loginBlobColor1.color.cgColor
        drawingLayer.lineWidth = 4.0
        
        let waveAnimGroup: CAAnimationGroup = CAAnimationGroup()
        waveAnimGroup.animations = [animStage0, animStage1, animStage2, animStage3, animStage4, animStage5, animStage6, animStage7]
        waveAnimGroup.duration = animStage3.beginTime + animStage3.duration
        waveAnimGroup.fillMode = CAMediaTimingFillMode.forwards
        waveAnimGroup.isRemovedOnCompletion = false
        waveAnimGroup.repeatCount = Float.infinity
        
        drawingLayer.add(waveAnimGroup, forKey: "waveCrest")
        refView.layer.addSublayer(drawingLayer)
        refView.layer.insertSublayer(drawingLayer, at: 0)
    }
}
