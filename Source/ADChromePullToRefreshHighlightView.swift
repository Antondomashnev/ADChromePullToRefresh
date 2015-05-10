//
//  ADChromePullToRefreshHighlightView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ADChromePullToRefreshHighlightView: UIView {

    private let minimumDeltaXToStartStretching: CGFloat = 30.0
    private let highlightLayerMaximumRadius: CGFloat = 30.0
    private let bezierCurveCorrectorValue: CGFloat = 40.2
    
    private var highlightLayer: CAShapeLayer!
    private var higlightLayerFillColor: UIColor = UIColor(red: 72.0/255.0, green: 132.0/255.0, blue: 232.0/255.0, alpha: 1.0)
    
    private var highlightedX: CGFloat = 0
    private var highlighted: Bool = false
    private var highlighting: Bool = false
    private var resetting: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addHighlightLayer()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    private func highlightLayerYForHeight(height: CGFloat) -> CGFloat {
        return (self.bounds.height - height) / 2
    }
    
    private func updateDeltaXForCenter(deltaX: CGFloat) -> CGFloat {
        return fabs(deltaX) / 8
    }
    
    private func updateDeltaXForStretchingSide(deltaX: CGFloat) -> CGFloat {
        return fabs(deltaX) / 4
    }
    
    private func updateDeltaXForOppositeStretchingSide(deltaX: CGFloat) -> CGFloat {
        return log(fabs(deltaX) + 1)
    }
    
    private func highlightedCirclePathIfTransformedFromLeftToRight() -> UIBezierPath {
        var newPath = UIBezierPath()
        let normalTopPoint = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let normalBottomPoint = CGPoint(x: self.highlightedX, y: normalTopPoint.y + self.highlightLayerMaximumRadius * 2)
        
        newPath.moveToPoint(normalTopPoint)
        
        let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalTopPoint.y)
        let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurveToPoint(normalBottomPoint, controlPoint1: rightControlPoint2, controlPoint2: rightControlPoint1)
        
        let leftControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalTopPoint.y)
        let leftControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurveToPoint(normalTopPoint, controlPoint1: leftControlPoint2, controlPoint2: leftControlPoint1)
        
        return newPath
    }
    
    private func highlightedCirclePathIfTransformedFromRightToLeft() -> UIBezierPath {
        var newPath = UIBezierPath()
        let normalTopPoint = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let normalBottomPoint = CGPoint(x: self.highlightedX, y: normalTopPoint.y + self.highlightLayerMaximumRadius * 2)
        
        newPath.moveToPoint(normalTopPoint)
        
        let leftControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalTopPoint.y)
        let leftControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurveToPoint(normalBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
        
        let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalTopPoint.y)
        let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurveToPoint(normalTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
        
        return newPath
    }
    
    private func normalCirclePath() -> UIBezierPath {
        let startOrigin = CGPoint(x: self.highlightedX - self.highlightLayerMaximumRadius, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let startPath = UIBezierPath(roundedRect: CGRect(origin: startOrigin, size: CGSize(width: self.highlightLayerMaximumRadius * 2, height: self.highlightLayerMaximumRadius * 2)), cornerRadius: self.highlightLayerMaximumRadius)
        return startPath
    }
    
    private func bigCirclePath() -> UIBezierPath {
        let newRadius = (max(self.bounds.width - self.highlightedX, self.highlightedX) + 200) / 2.0
        let endOrigin = CGPoint(x: self.highlightedX - newRadius, y: self.highlightLayerYForHeight(newRadius * 2))
        let endPath = UIBezierPath(roundedRect: CGRect(origin: endOrigin, size: CGSize(width: newRadius * 2, height: newRadius * 2)), cornerRadius: newRadius)
        return endPath
    }
    
    private func zeroCirclePath() -> UIBezierPath {
        let startOrigin = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(0.0))
        let startPath = UIBezierPath(roundedRect: CGRect(origin: startOrigin, size: CGSize.zeroSize), cornerRadius: 1)
        return startPath
    }
    
    //MARK: - UI
    
    private func addHighlightLayer() {
        self.highlightLayer = CAShapeLayer()
        self.highlightLayer.fillColor = self.higlightLayerFillColor.CGColor
        self.highlightLayer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.addSublayer(self.highlightLayer)
    }
    
    //MARK: - CABasicAnimationDelegate
    
    override func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        if self.highlightLayer.animationForKey("resetAnimation") != nil && anim == self.highlightLayer.animationForKey("resetAnimation") {
            self.highlightLayer.removeAllAnimations()
            self.highlightLayer.path = UIBezierPath(rect: CGRect.zeroRect).CGPath
            self.resetting = false
        }
        else if self.highlightLayer.animationForKey("highlightAnimation") != nil &&  anim == self.highlightLayer.animationForKey("highlightAnimation") {
            self.highlighting = false
        }
    }
    
    //MARK: - Interface
    
    func reset() {
        if !self.highlighted || self.resetting {
            return
        }

        self.resetting = true
        
        let endPath = self.bigCirclePath()
        let startPath = UIBezierPath(CGPath: self.highlightLayer.path)
        
        let animationGroup = CAAnimationGroup()
        animationGroup.fillMode = kCAFillModeForwards
        animationGroup.removedOnCompletion = false
        animationGroup.delegate = self
        animationGroup.duration = 0.3
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = self.highlightLayer.path
        pathAnimation.toValue = endPath.CGPath
        pathAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        
        animationGroup.animations = [pathAnimation, opacityAnimation]
        
        self.highlightLayer.opacity = 0
        self.highlightLayer.path = endPath.CGPath
        self.highlightLayer.addAnimation(animationGroup, forKey: "resetAnimation")
        
        self.highlighted = false
        self.highlightedX = 0
    }
    
    func highlightActionViewAtPoint(x: CGFloat) {
        if self.highlightedX == x {
            return
        }
        
        let oldHighlightedX = self.highlightedX
        self.highlightedX = x
        self.highlighting = true
        
        var startCGPath: CGPath? = nil
        var endCGPath: CGPath? = nil
        if (!self.highlighted) {
            startCGPath = self.zeroCirclePath().CGPath
            endCGPath = self.normalCirclePath().CGPath
        }
        else {
            startCGPath = self.highlightLayer.path
            if oldHighlightedX > x {
                endCGPath = self.highlightedCirclePathIfTransformedFromRightToLeft().CGPath
            }
            else {
                endCGPath = self.highlightedCirclePathIfTransformedFromLeftToRight().CGPath
            }
        }
        
        self.highlightLayer.path = startCGPath!
        self.highlightLayer.opacity = 1
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue =  endCGPath!
        animation.duration = 0.3
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.removedOnCompletion = false
        self.highlightLayer.addAnimation(animation, forKey: "highlightAnimation")
        
        self.highlighted = true
    }
    
    func setDeltaX(x: CGFloat) {
        
        if self.highlighting || self.resetting {
            return
        }
        
        let normalTop = self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2)
        let normalBottom = normalTop + self.highlightLayerMaximumRadius * 2
        
        let centerY = normalTop + self.highlightLayerMaximumRadius
        if x >= -minimumDeltaXToStartStretching && x <= minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            self.highlightLayer.opacity = 1
            self.highlightLayer.path = self.normalCirclePath().CGPath
        }
        else if x < -minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            
            let updatedX = x + minimumDeltaXToStartStretching
            var newPath = UIBezierPath()
            let newX = self.highlightedX - self.updateDeltaXForCenter(updatedX)
            let updatedTopPoint = CGPoint(x: newX, y: normalTop)
            let updatedBottomPoint = CGPoint(x: newX, y: normalBottom)
            
            newPath.moveToPoint(updatedTopPoint)
            
            let stretchingDeltaX = self.updateDeltaXForStretchingSide(updatedX)
            let leftControlPoint1 = CGPoint(x: newX - bezierCurveCorrectorValue - stretchingDeltaX, y: normalTop)
            let leftControlPoint2 = CGPoint(x: newX - bezierCurveCorrectorValue - stretchingDeltaX, y: normalBottom)
            newPath.addCurveToPoint(updatedBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
            
            let oppositeStretchingDeltaX = self.updateDeltaXForOppositeStretchingSide(updatedX)
            let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue - oppositeStretchingDeltaX, y: normalTop)
            let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue - oppositeStretchingDeltaX, y: normalBottom)
            newPath.addCurveToPoint(updatedTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
            
            self.highlightLayer.path = newPath.CGPath
        }
        else if x > minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            
            let updatedX = x - minimumDeltaXToStartStretching
            var newPath = UIBezierPath()
            let newX = self.highlightedX + self.updateDeltaXForCenter(updatedX)
            let updatedTopPoint = CGPoint(x: newX, y: normalTop)
            let updatedBottomPoint = CGPoint(x: newX, y: normalBottom)
            
            newPath.moveToPoint(updatedTopPoint)
            
            let stretchingDeltaX = self.updateDeltaXForStretchingSide(updatedX)
            let leftControlPoint1 = CGPoint(x: newX + bezierCurveCorrectorValue + stretchingDeltaX, y: normalTop)
            let leftControlPoint2 = CGPoint(x: newX + bezierCurveCorrectorValue + stretchingDeltaX, y: normalBottom)
            newPath.addCurveToPoint(updatedBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
            
            let oppositeStretchingDeltaX = self.updateDeltaXForOppositeStretchingSide(updatedX)
            let rightControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue + oppositeStretchingDeltaX, y: normalTop)
            let rightControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue + oppositeStretchingDeltaX, y: normalBottom)
            newPath.addCurveToPoint(updatedTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
            self.highlightLayer.path = newPath.CGPath
        }
    }
}
