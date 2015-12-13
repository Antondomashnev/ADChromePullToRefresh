//
//  ADChromePullToRefreshView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

protocol ADChromePullToRefreshViewDelegate: NSObjectProtocol {
    func chromePullToRefreshViewDidChangeHighlightedView(newHighlightedActionViewType: ADChromePullToRefreshActionViewType?)
    func chromePullToRefreshView(view: ADChromePullToRefreshView, actionViewWithType type: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
}

class ADChromePullToRefreshView: UIView {
    
    weak var delegate: ADChromePullToRefreshViewDelegate!
    
    private var leftActionViewHeightConstraint: NSLayoutConstraint!
    private var rightActionViewHeightConstraint: NSLayoutConstraint!
    private var refreshViewHeightConstraint: NSLayoutConstraint!
    
    internal let deltaToChangeHighlightedItem: CGFloat = 100

    private let highlightScrollProgress: CGFloat = 0.95
    private let leftActionLeftMargin: CGFloat = 60.0
    private let rightActionRightMargin: CGFloat = 60.0
    private let viewsSize = CGSize(width: 22.0, height: 22.0)
    private let highlightViewHeight: CGFloat = 60.0

    private var centerActionView: ADChromePullToRefreshActionView!
    private var leftActionView: ADChromePullToRefreshActionView!
    private var rightActionView: ADChromePullToRefreshActionView!
    private var highlightView: ADChromePullToRefreshHighlightView!
    
    init(frame: CGRect, delegate: ADChromePullToRefreshViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    private func commonInit() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        self.addHighlightView()
        self.addCenterActionView()
        self.addLeftActionView()
        self.addRightActionView()
    }
    
    //MARK: - Helpers
    
    func heightConstraintForActionView(view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.viewsSize.height)
    }
    
    func heightConstraintForHighlightView(view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.highlightViewHeight)
    }
    
    func centerYConstraintForView(view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1.0, constant: 0)
    }
    
    //MARK: - UI
    
    private func addHighlightView() {
        self.highlightView = ADChromePullToRefreshHighlightView(frame: self.bounds)
        self.addSubview(self.highlightView)
    }
    
    private func addCenterActionView() {
        self.centerActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .Center)
        self.addSubview(self.centerActionView)
    }
    
    private func addLeftActionView() {
        self.leftActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .Left)
        self.addSubview(self.leftActionView)
    }
    
    private func addRightActionView() {
        self.rightActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .Right)
        self.addSubview(self.rightActionView)
    }
    
    //MARK: - Interface
    
    // scrollProgress == 1 - pull to refresh UI
    // scrollProgress == 0 - initial UI
    func updateUIWithScrollProgress(scrollProgress: CGFloat) {
        self.alpha = scrollProgress > 0.0 ? 1.0 : 0.0
        self.leftActionView.updateWithScrollProgress(scrollProgress)
        self.rightActionView.updateWithScrollProgress(scrollProgress)
        self.centerActionView.updateWithScrollProgress(scrollProgress)
        
        if scrollProgress >= self.highlightScrollProgress {
            if self.leftActionView.isHighlighted() || self.centerActionView.isHighlighted() || self.rightActionView.isHighlighted() {
                return
            }
            self.highlightView.highlightActionViewAtPoint(self.centerActionView.center.x)
            self.centerActionView.setHighighted(true)
            self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(ADChromePullToRefreshActionViewType.Center)
        }
        else {
            self.highlightView.reset()
            self.centerActionView.setHighighted(false)
            self.leftActionView.setHighighted(false)
            self.rightActionView.setHighighted(false)
            self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(nil)
        }
    }
    
    func updateUIWithXDelta(delta: CGFloat) -> Bool {
        self.highlightView.setDeltaX(delta)
        if delta < -self.deltaToChangeHighlightedItem {
            if self.leftActionView.isHighlighted() {
                return false
            }
            else if self.centerActionView.isHighlighted() {
                self.leftActionView.setHighighted(true)
                self.centerActionView.setHighighted(false)
                self.highlightView.highlightActionViewAtPoint(self.leftActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(ADChromePullToRefreshActionViewType.Left)
            }
            else {
                self.rightActionView.setHighighted(false)
                self.centerActionView.setHighighted(true)
                self.highlightView.highlightActionViewAtPoint(self.centerActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(ADChromePullToRefreshActionViewType.Center)
            }
        }
        else if delta > self.deltaToChangeHighlightedItem {
            if self.leftActionView.isHighlighted() {
                self.leftActionView.setHighighted(false)
                self.centerActionView.setHighighted(true)
                self.highlightView.highlightActionViewAtPoint(self.centerActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(ADChromePullToRefreshActionViewType.Center)
            }
            else if self.centerActionView.isHighlighted() {
                self.rightActionView.setHighighted(true)
                self.centerActionView.setHighighted(false)
                self.highlightView.highlightActionViewAtPoint(self.rightActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(ADChromePullToRefreshActionViewType.Right)
            }
            else {
                return false
            }
        }
        return true
    }
    
    func setUpConstraints() {
        let verticalMargin = (self.bounds.height - self.viewsSize.height) / 2
        let horizontalMargin = (self.bounds.width - self.viewsSize.width * 3 - self.leftActionLeftMargin - self.rightActionRightMargin) / 2
        let viewsDictionary = ["refreshView" : self.centerActionView, "leftActionView" : self.leftActionView, "rightActionView" : self.rightActionView, "highlightView": self.highlightView]
        let metricsDictionary = ["leftActionLeft": self.leftActionLeftMargin, "rightActionRight": self.rightActionRightMargin, "viewsMargin": horizontalMargin, "viewWidth": self.viewsSize.width, "viewHeight": self.viewsSize.height, "verticalMargin": verticalMargin]
        let horizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("|-(leftActionLeft)-[leftActionView(viewWidth)]-(viewsMargin)-[refreshView(viewWidth)]-(viewsMargin)-[rightActionView(viewWidth)]-(rightActionRight)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metricsDictionary as [String : AnyObject], views: viewsDictionary)
        self.addConstraints(horizontalConstraints)
        
        let actionViews = [self.centerActionView, self.leftActionView, self.rightActionView]
        for actionView in actionViews {
            self.addConstraint(self.centerYConstraintForView(actionView))
        }
        
        self.refreshViewHeightConstraint = self.heightConstraintForActionView(self.centerActionView)
        self.leftActionViewHeightConstraint = self.heightConstraintForActionView(self.leftActionView)
        self.rightActionViewHeightConstraint = self.heightConstraintForActionView(self.rightActionView)
        
        self.centerActionView.addConstraint(self.refreshViewHeightConstraint)
        self.leftActionView.addConstraint(self.leftActionViewHeightConstraint)
        self.rightActionView.addConstraint(self.rightActionViewHeightConstraint)
        
        for actionView in actionViews {
            actionView.setUpConstraints()
        }
        
        let highlightHorizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraintsWithVisualFormat("H:|[highlightView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(highlightHorizontalConstraints)
        self.addConstraint(self.centerYConstraintForView(self.highlightView))
        self.addConstraint(self.heightConstraintForHighlightView(self.highlightView))
        
        self.layoutIfNeeded()
    }
}
