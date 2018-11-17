//
//  ADChromePullToRefreshView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

public protocol ADChromePullToRefreshViewDelegate: NSObjectProtocol {
    func chromePullToRefreshViewDidChangeHighlightedView(_ newHighlightedActionViewType: ADChromePullToRefreshActionViewType?)
    func chromePullToRefreshView(_ view: ADChromePullToRefreshView, actionViewWithType type: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
}

public class ADChromePullToRefreshView: UIView {
    
    weak var delegate: ADChromePullToRefreshViewDelegate!
    
    fileprivate var leftActionViewHeightConstraint: NSLayoutConstraint!
    fileprivate var rightActionViewHeightConstraint: NSLayoutConstraint!
    fileprivate var refreshViewHeightConstraint: NSLayoutConstraint!
    
    internal let deltaToChangeHighlightedItem: CGFloat = 100

    fileprivate let highlightScrollProgress: CGFloat = 0.95
    fileprivate let leftActionLeftMargin: CGFloat = 60.0
    fileprivate let rightActionRightMargin: CGFloat = 60.0
    fileprivate let viewsSize = CGSize(width: 22.0, height: 22.0)
    fileprivate let highlightViewHeight: CGFloat = 60.0

    fileprivate var centerActionView: ADChromePullToRefreshActionView!
    fileprivate var leftActionView: ADChromePullToRefreshActionView!
    fileprivate var rightActionView: ADChromePullToRefreshActionView!
    fileprivate var highlightView: ADChromePullToRefreshHighlightView!
    
    init(frame: CGRect, delegate: ADChromePullToRefreshViewDelegate) {
        super.init(frame: frame)
        self.delegate = delegate
        self.commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    fileprivate func commonInit() {
        self.clipsToBounds = true
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = UIColor(red: 250.0/255.0, green: 250.0/255.0, blue: 250.0/255.0, alpha: 1.0)
        self.addHighlightView()
        self.addCenterActionView()
        self.addLeftActionView()
        self.addRightActionView()
    }
    
    //MARK: - Helpers
    
    func heightConstraintForActionView(_ view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.viewsSize.height)
    }
    
    func heightConstraintForHighlightView(_ view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.highlightViewHeight)
    }
    
    func centerYConstraintForView(_ view: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
    }
    
    //MARK: - UI
    
    fileprivate func addHighlightView() {
        self.highlightView = ADChromePullToRefreshHighlightView(frame: self.bounds)
        self.addSubview(self.highlightView)
    }
    
    fileprivate func addCenterActionView() {
        self.centerActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .center)
        self.addSubview(self.centerActionView)
    }
    
    fileprivate func addLeftActionView() {
        self.leftActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .left)
        self.addSubview(self.leftActionView)
    }
    
    fileprivate func addRightActionView() {
        self.rightActionView = self.delegate!.chromePullToRefreshView(self, actionViewWithType: .right)
        self.addSubview(self.rightActionView)
    }
    
    //MARK: - Interface
    
    // scrollProgress == 1 - pull to refresh UI
    // scrollProgress == 0 - initial UI
    func updateUIWithScrollProgress(_ scrollProgress: CGFloat) {
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
            self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(.center)
        }
        else {
            self.highlightView.reset()
            self.centerActionView.setHighighted(false)
            self.leftActionView.setHighighted(false)
            self.rightActionView.setHighighted(false)
            self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(nil)
        }
    }

	@discardableResult
    func updateUIWithXDelta(_ delta: CGFloat) -> Bool {
        self.highlightView.setDeltaX(delta)
        if delta < -self.deltaToChangeHighlightedItem {
            if self.leftActionView.isHighlighted() {
                return false
            }
            else if self.centerActionView.isHighlighted() {
                self.leftActionView.setHighighted(true)
                self.centerActionView.setHighighted(false)
                self.highlightView.highlightActionViewAtPoint(self.leftActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(.left)
            }
            else {
                self.rightActionView.setHighighted(false)
                self.centerActionView.setHighighted(true)
                self.highlightView.highlightActionViewAtPoint(self.centerActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(.center)
            }
        }
        else if delta > self.deltaToChangeHighlightedItem {
            if self.leftActionView.isHighlighted() {
                self.leftActionView.setHighighted(false)
                self.centerActionView.setHighighted(true)
                self.highlightView.highlightActionViewAtPoint(self.centerActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(.center)
            }
            else if self.centerActionView.isHighlighted() {
                self.rightActionView.setHighighted(true)
                self.centerActionView.setHighighted(false)
                self.highlightView.highlightActionViewAtPoint(self.rightActionView.center.x)
                self.delegate?.chromePullToRefreshViewDidChangeHighlightedView(.right)
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
        let viewsDictionary: [String : UIView] = ["refreshView" : self.centerActionView, "leftActionView" : self.leftActionView, "rightActionView" : self.rightActionView, "highlightView": self.highlightView]
        let metricsDictionary: [String : CGFloat] = ["leftActionLeft": self.leftActionLeftMargin, "rightActionRight": self.rightActionRightMargin, "viewsMargin": horizontalMargin, "viewWidth": self.viewsSize.width, "viewHeight": self.viewsSize.height, "verticalMargin": verticalMargin]
        let horizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "|-(leftActionLeft)-[leftActionView(viewWidth)]-(viewsMargin)-[refreshView(viewWidth)]-(viewsMargin)-[rightActionView(viewWidth)]-(rightActionRight)-|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: metricsDictionary as [String : AnyObject], views: viewsDictionary)
        self.addConstraints(horizontalConstraints)
        
        let actionViews: [ADChromePullToRefreshActionView] = [self.centerActionView, self.leftActionView, self.rightActionView]
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
        
        let highlightHorizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|[highlightView]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(highlightHorizontalConstraints)
        self.addConstraint(self.centerYConstraintForView(self.highlightView))
        self.addConstraint(self.heightConstraintForHighlightView(self.highlightView))
        
        self.layoutIfNeeded()
    }
}
