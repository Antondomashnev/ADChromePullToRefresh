//
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/18/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import Foundation
import UIKit


class ADChromePullToRefresh: NSObject {
    
    private var context = "com.antondomashnev.ADChromePullToRefresh.KVOContext"
    private var isObserved: Bool = false
    private var isPanGestureHandlerAdded: Bool = false
    private var lastObservedOffsetY: CGFloat = 0.0
    
    private var pullToRefreshStartPanGestureX: CGFloat = 0.0
    private var pullToRefreshScrollProgress: CGFloat = 0.0 {
        didSet {
            if self.pullToRefreshScrollProgress >= 1.0 {
                if !self.isPanGestureHandlerAdded {
                    self.isPanGestureHandlerAdded = true
                    self.pullToRefreshStartPanGestureX = self.scrollView.panGestureRecognizer.locationInView(self.pullToRefreshSuperview).x
                    self.scrollView.panGestureRecognizer.addTarget(self, action: "handleScrollViewPanGesture:")
                }
            }
            else {
                if self.isPanGestureHandlerAdded {
                    self.isPanGestureHandlerAdded = false
                    self.pullToRefreshStartPanGestureX = 0.0
                    self.scrollView.panGestureRecognizer.removeTarget(self, action: "handleScrollViewPanGesture:")
                }
            }
        }
    }
    private var pullToRefreshView: ADChromePullToRefreshView!
    private var pullToRefreshViewHeightConstraint: NSLayoutConstraint!
    
    private let scrollViewOriginalOffsetY: CGFloat
    private let scrollViewOffsetYDeltaForOneAlpha: CGFloat = 80
    private let scrollViewOffsetYDeltaForTopViewZeroAlpha: CGFloat = 20
    
    private weak var scrollView: UIScrollView!
    private weak var topView: UIView!
    private weak var pullToRefreshSuperview: UIView!
    
    init(view: UIView, topViewOriginalAlpha: CGFloat, forScrollView scrollView: UIScrollView, scrollViewOriginalOffsetY: CGFloat) {
        if view.superview == nil {
            assert(false, "can't add pull to refresh view to nil")
        }
        self.scrollViewOriginalOffsetY = scrollViewOriginalOffsetY
        self.scrollView = scrollView
        self.topView = view
        self.pullToRefreshSuperview = self.topView.superview
        super.init()
        self.createPullToRefreshView()
        self.subscribeOnScrollViewContentOffset()
    }
    
    deinit {
        self.unsubscribeFromScrollViewContentOffset()
    }
    
    //MARK: - Interface
    
    func setUpConstraints() {
        let viewsDictionary = ["pullToRefresh" : self.pullToRefreshView]
        let horizontalConstraints: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[pullToRefresh]|", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        self.pullToRefreshSuperview.addConstraints(horizontalConstraints as [AnyObject])
        let verticalConstraints: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|[pullToRefresh]", options: NSLayoutFormatOptions(0), metrics: nil, views: viewsDictionary)
        self.pullToRefreshSuperview.addConstraints(verticalConstraints as [AnyObject])
        
        self.pullToRefreshViewHeightConstraint = NSLayoutConstraint(item: self.pullToRefreshView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: self.topView.bounds.height)
        self.pullToRefreshView.addConstraint(self.pullToRefreshViewHeightConstraint)
        
        self.pullToRefreshSuperview.layoutIfNeeded()
        self.pullToRefreshView.setUpConstraints()
    }
    
    //MARK: - Helpers
    
    func subscribeOnScrollViewContentOffset() {
        if self.isObserved {
            return
        }
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: &context)
    }
    
    func unsubscribeFromScrollViewContentOffset() {
        if !self.isObserved {
            return
        }
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset", context: &context)
    }
    
    func updateViewsWithNewOffsetY(offsetY: CGFloat) {
        if offsetY >= self.scrollViewOriginalOffsetY {
            self.topView.alpha = 1
            self.pullToRefreshView.alpha = 0
            self.pullToRefreshViewHeightConstraint.constant = self.topView.bounds.height
            return
        }
        
        let delta = (fabs(offsetY) - self.scrollViewOriginalOffsetY)
        let topViewCoefficient = delta / scrollViewOffsetYDeltaForTopViewZeroAlpha
        let newTopViewAlpha = max(0, 1 - topViewCoefficient)
        self.topView.alpha = newTopViewAlpha
        
        self.pullToRefreshScrollProgress = min(1, max(0, (delta - scrollViewOffsetYDeltaForTopViewZeroAlpha) / scrollViewOffsetYDeltaForOneAlpha))
        self.pullToRefreshView.updateUIWithScrollProgress(self.pullToRefreshScrollProgress)
        
        let newPullToRefreshHeight = delta + self.topView.bounds.height
        self.pullToRefreshViewHeightConstraint.constant = newPullToRefreshHeight
    }
    
    //MARK: - Gestures
    
    private var i = 0
    func handleScrollViewPanGesture(panGesture: UIPanGestureRecognizer) {
        if !self.isPanGestureHandlerAdded {
            return
        }
        
        let currentX = panGesture.locationInView(self.pullToRefreshSuperview).x
        let delta = currentX - self.pullToRefreshStartPanGestureX
        if self.pullToRefreshView.updateUIWithXDelta(delta) {
            if fabs(delta) > self.pullToRefreshView.deltaToChangeHighlightedItem {
                self.pullToRefreshStartPanGestureX = currentX
            }
        }
    }
    
    //MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &self.context {
            return
        }
        
        let newOffsetY = self.scrollView.contentOffset.y
        self.updateViewsWithNewOffsetY(newOffsetY)
        self.lastObservedOffsetY = newOffsetY
    }
    
    //MARK: - UI
    
    func createPullToRefreshView() {
        self.pullToRefreshView = ADChromePullToRefreshView(frame: self.topView.bounds)
        self.pullToRefreshSuperview.addSubview(self.pullToRefreshView)
    }
}
