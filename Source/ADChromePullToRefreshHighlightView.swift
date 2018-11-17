//
//  ADChromePullToRefreshHighlightView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

public class ADChromePullToRefreshHighlightView: UIView, CAAnimationDelegate {

    fileprivate let minimumDeltaXToStartStretching: CGFloat = 30.0
    fileprivate let highlightLayerMaximumRadius: CGFloat = 30.0
    fileprivate let bezierCurveCorrectorValue: CGFloat = 40.2
    
    fileprivate var highlightLayer: CAShapeLayer!
    fileprivate var higlightLayerFillColor: UIColor = UIColor(red: 72.0/255.0, green: 132.0/255.0, blue: 232.0/255.0, alpha: 1.0)
    
    fileprivate var highlightedX: CGFloat = 0
    fileprivate var highlighted: Bool = false
    fileprivate var highlighting: Bool = false
    fileprivate var resetting: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addHighlightLayer()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    
    fileprivate func highlightLayerYForHeight(_ height: CGFloat) -> CGFloat {
        return (self.bounds.height - height) / 2
    }
    
    fileprivate func updateDeltaXForCenter(_ deltaX: CGFloat) -> CGFloat {
        return abs(deltaX) / 6
    }
    
    fileprivate func updateDeltaXForStretchingSide(_ deltaX: CGFloat) -> CGFloat {
        return abs(deltaX) / 3
    }
    
    fileprivate func updateDeltaXForOppositeStretchingSide(_ deltaX: CGFloat) -> CGFloat {
        return log(abs(deltaX) + 1)
    }
    
    fileprivate func highlightedCirclePathIfTransformedFromLeftToRight() -> UIBezierPath {
        let newPath = UIBezierPath()
        let normalTopPoint = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let normalBottomPoint = CGPoint(x: self.highlightedX, y: normalTopPoint.y + self.highlightLayerMaximumRadius * 2)
        
        newPath.move(to: normalTopPoint)
        
        let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalTopPoint.y)
        let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurve(to: normalBottomPoint, controlPoint1: rightControlPoint2, controlPoint2: rightControlPoint1)
        
        let leftControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalTopPoint.y)
        let leftControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurve(to: normalTopPoint, controlPoint1: leftControlPoint2, controlPoint2: leftControlPoint1)
        
        return newPath
    }
    
    fileprivate func highlightedCirclePathIfTransformedFromRightToLeft() -> UIBezierPath {
        let newPath = UIBezierPath()
        let normalTopPoint = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let normalBottomPoint = CGPoint(x: self.highlightedX, y: normalTopPoint.y + self.highlightLayerMaximumRadius * 2)
        
        newPath.move(to: normalTopPoint)
        
        let leftControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalTopPoint.y)
        let leftControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurve(to: normalBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
        
        let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalTopPoint.y)
        let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue, y: normalBottomPoint.y)
        newPath.addCurve(to: normalTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
        
        return newPath
    }
    
    fileprivate func normalCirclePath() -> UIBezierPath {
        let startOrigin = CGPoint(x: self.highlightedX - self.highlightLayerMaximumRadius, y: self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2))
        let startPath = UIBezierPath(roundedRect: CGRect(origin: startOrigin, size: CGSize(width: self.highlightLayerMaximumRadius * 2, height: self.highlightLayerMaximumRadius * 2)), cornerRadius: self.highlightLayerMaximumRadius)
        return startPath
    }
    
    fileprivate func bigCirclePath() -> UIBezierPath {
        let newRadius = (max(self.bounds.width - self.highlightedX, self.highlightedX) + 200) / 2.0
        let endOrigin = CGPoint(x: self.highlightedX - newRadius, y: self.highlightLayerYForHeight(newRadius * 2))
        let endPath = UIBezierPath(roundedRect: CGRect(origin: endOrigin, size: CGSize(width: newRadius * 2, height: newRadius * 2)), cornerRadius: newRadius)
        return endPath
    }
    
    fileprivate func zeroCirclePath() -> UIBezierPath {
        let startOrigin = CGPoint(x: self.highlightedX, y: self.highlightLayerYForHeight(0.0))
        let startPath = UIBezierPath(roundedRect: CGRect(origin: startOrigin, size: CGSize.zero), cornerRadius: 1)
        return startPath
    }
    
    //MARK: - UI
    
    fileprivate func addHighlightLayer() {
        self.highlightLayer = CAShapeLayer()
        self.highlightLayer.fillColor = self.higlightLayerFillColor.cgColor
        self.highlightLayer.anchorPoint = CGPoint(x: 1.0, y: 1.0)
        self.layer.addSublayer(self.highlightLayer)
    }
    
    //MARK: - CABasicAnimationDelegate
    
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if self.highlightLayer.animation(forKey: "resetAnimation") != nil && anim == self.highlightLayer.animation(forKey: "resetAnimation") {
            self.highlightLayer.removeAllAnimations()
            self.highlightLayer.path = UIBezierPath(rect: CGRect.zero).cgPath
            self.resetting = false
        }
        else if self.highlightLayer.animation(forKey: "highlightAnimation") != nil &&  anim == self.highlightLayer.animation(forKey: "highlightAnimation") {
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
        
        let animationGroup = CAAnimationGroup()
        animationGroup.fillMode = CAMediaTimingFillMode.forwards
        animationGroup.isRemovedOnCompletion = false
        animationGroup.delegate = self
        animationGroup.duration = 0.3
        
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.fromValue = self.highlightLayer.path
        pathAnimation.toValue = endPath.cgPath
        pathAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 1
        opacityAnimation.toValue = 0
        opacityAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        
        animationGroup.animations = [pathAnimation, opacityAnimation]
        
        self.highlightLayer.opacity = 0
        self.highlightLayer.path = endPath.cgPath
        self.highlightLayer.add(animationGroup, forKey: "resetAnimation")
        
        self.highlighted = false
        self.highlightedX = 0
    }
    
    func highlightActionViewAtPoint(_ x: CGFloat) {
        if self.highlightedX == x {
            return
        }
        
        let oldHighlightedX = self.highlightedX
        self.highlightedX = x
        self.highlighting = true
        
        var duration: TimeInterval = 0
        var startCGPath: CGPath? = nil
        var endCGPath: CGPath? = nil
        if (!self.highlighted) {
            startCGPath = self.zeroCirclePath().cgPath
            endCGPath = self.normalCirclePath().cgPath
            duration = 0.3
        }
        else {
            duration = 0.2
            startCGPath = self.highlightLayer.path
            if oldHighlightedX > x {
                endCGPath = self.highlightedCirclePathIfTransformedFromRightToLeft().cgPath
            }
            else {
                endCGPath = self.highlightedCirclePathIfTransformedFromLeftToRight().cgPath
            }
        }
        
        self.highlightLayer.path = startCGPath!
        self.highlightLayer.opacity = 1
        
        let animation = CABasicAnimation(keyPath: "path")
        animation.toValue =  endCGPath!
        animation.duration = duration
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.isRemovedOnCompletion = false
        self.highlightLayer.add(animation, forKey: "highlightAnimation")
        
        self.highlighted = true
    }
    
    func setDeltaX(_ x: CGFloat) {
        
        if self.highlighting || self.resetting {
            return
        }
        
        let normalTop = self.highlightLayerYForHeight(self.highlightLayerMaximumRadius * 2)
        let normalBottom = normalTop + self.highlightLayerMaximumRadius * 2
        
        if x >= -minimumDeltaXToStartStretching && x <= minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            self.highlightLayer.opacity = 1
            self.highlightLayer.path = self.normalCirclePath().cgPath
        }
        else if x < -minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            
            let updatedX = x + minimumDeltaXToStartStretching
            let newPath = UIBezierPath()
            let newX = self.highlightedX - self.updateDeltaXForCenter(updatedX)
            let updatedTopPoint = CGPoint(x: newX, y: normalTop)
            let updatedBottomPoint = CGPoint(x: newX, y: normalBottom)
            
            newPath.move(to: updatedTopPoint)
            
            let stretchingDeltaX = self.updateDeltaXForStretchingSide(updatedX)
            let leftControlPoint1 = CGPoint(x: newX - bezierCurveCorrectorValue - stretchingDeltaX, y: normalTop)
            let leftControlPoint2 = CGPoint(x: newX - bezierCurveCorrectorValue - stretchingDeltaX, y: normalBottom)
            newPath.addCurve(to: updatedBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
            
            let oppositeStretchingDeltaX = self.updateDeltaXForOppositeStretchingSide(updatedX)
            let rightControlPoint2 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue - oppositeStretchingDeltaX, y: normalTop)
            let rightControlPoint1 = CGPoint(x: self.highlightedX + bezierCurveCorrectorValue - oppositeStretchingDeltaX, y: normalBottom)
            newPath.addCurve(to: updatedTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
            
            self.highlightLayer.path = newPath.cgPath
        }
        else if x > minimumDeltaXToStartStretching {
            self.highlightLayer.removeAllAnimations()
            
            let updatedX = x - minimumDeltaXToStartStretching
            let newPath = UIBezierPath()
            let newX = self.highlightedX + self.updateDeltaXForCenter(updatedX)
            let updatedTopPoint = CGPoint(x: newX, y: normalTop)
            let updatedBottomPoint = CGPoint(x: newX, y: normalBottom)
            
            newPath.move(to: updatedTopPoint)
            
            let stretchingDeltaX = self.updateDeltaXForStretchingSide(updatedX)
            let leftControlPoint1 = CGPoint(x: newX + bezierCurveCorrectorValue + stretchingDeltaX, y: normalTop)
            let leftControlPoint2 = CGPoint(x: newX + bezierCurveCorrectorValue + stretchingDeltaX, y: normalBottom)
            newPath.addCurve(to: updatedBottomPoint, controlPoint1: leftControlPoint1, controlPoint2: leftControlPoint2)
            
            let oppositeStretchingDeltaX = self.updateDeltaXForOppositeStretchingSide(updatedX)
            let rightControlPoint2 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue + oppositeStretchingDeltaX, y: normalTop)
            let rightControlPoint1 = CGPoint(x: self.highlightedX - bezierCurveCorrectorValue + oppositeStretchingDeltaX, y: normalBottom)
            newPath.addCurve(to: updatedTopPoint, controlPoint1: rightControlPoint1, controlPoint2: rightControlPoint2)
            self.highlightLayer.path = newPath.cgPath
        }
    }
}
