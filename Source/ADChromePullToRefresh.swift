//
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/18/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import Foundation
import UIKit

typealias ADChromePullToRefreshAction = () -> Void

protocol ADChromePullToRefreshDelegate: NSObjectProtocol {
    func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
    func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction?
}


class ADChromePullToRefresh: NSObject, ADChromePullToRefreshViewDelegate {
    
    weak var delegate: ADChromePullToRefreshDelegate?
    
    private var state: ADChromePullToRefreshState = ADChromePullToRefreshState.Stopped {
        didSet {
            if self.highlightedActionViewType == .Center {
                self.updateForState(self.state)
            }
        }
    }
    
    private var highlightedActionViewType: ADChromePullToRefreshActionViewType?
    
    private let scrollViewOriginalTopInset: CGFloat
    private let scrollViewOriginalOffsetY: CGFloat
    private let scrollViewOffsetYDeltaForOneAlpha: CGFloat = 80
    private let scrollViewOffsetYDeltaForTopViewZeroAlpha: CGFloat = 20
    private let pullToRefreshTreschold: CGFloat = -90.0
    
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
    
    private weak var scrollView: UIScrollView!
    private weak var topView: UIView!
    private weak var pullToRefreshSuperview: UIView!
    
    init(view: UIView, forScrollView scrollView: UIScrollView, scrollViewOriginalOffsetY: CGFloat, delegate: ADChromePullToRefreshDelegate) {
        if view.superview == nil {
            assert(false, "can't add pull to refresh view to nil")
        }
        
        self.delegate = delegate
        self.scrollViewOriginalOffsetY = scrollViewOriginalOffsetY
        self.scrollView = scrollView
        self.scrollViewOriginalTopInset = self.scrollView.contentInset.top
        self.topView = view
        self.pullToRefreshSuperview = self.topView.superview
            
        super.init()
            
        self.createPullToRefreshView()
        self.subscribeOnScrollViewContentOffset()
    }
    
    deinit {
        self.unsubscribeFromScrollViewContentOffset()
    }
    
    //MARK: - ADChromePullToRefreshViewDelegate
    
    func chromePullToRefreshViewDidChangeHighlightedView(newHighlightedActionViewType: ADChromePullToRefreshActionViewType?) {
        self.pullToRefreshStartPanGestureX = self.scrollView.panGestureRecognizer.locationInView(self.pullToRefreshSuperview).x
        self.highlightedActionViewType = newHighlightedActionViewType
    }
    
    func chromePullToRefreshView(view: ADChromePullToRefreshView, actionViewWithType type: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView {
        return self.delegate!.chromePullToRefresh(self, viewWithType: type)
    }
    
    //MARK: - Interface
    
    func completePullToRefresh() {
        if self.state != .Loading {
            return
        }
        self.state = .Stopped
    }
    
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
    
    func setScrollViewContentInset(contentInset: UIEdgeInsets, scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let temporaryOffsetY = currentOffsetY + scrollView.contentInset.top
        let offsetX = scrollView.contentOffset.x
        scrollView.setContentOffset(CGPoint(x: offsetX, y: temporaryOffsetY), animated: true)
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.3 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            scrollView.contentInset = contentInset
        }
    }
    
    func resetScrollViewContentInset() {
        var currentInsets = self.scrollView.contentInset
        currentInsets.top = self.scrollViewOriginalTopInset
        self.setScrollViewContentInset(currentInsets, scrollView: self.scrollView)
    }
    
    func setScrollViewContentInsetForLoading() {
        let offset = max(self.scrollView.contentOffset.y * -1, 0)
        var currentInsets = self.scrollView.contentInset
        currentInsets.top = min(offset, self.scrollViewOriginalTopInset + CGRectGetHeight(self.pullToRefreshView.bounds))
        self.setScrollViewContentInset(currentInsets, scrollView: self.scrollView)
    }
    
    func updateForState(newState: ADChromePullToRefreshState) {
        switch state {
        case .Stopped:
            self.resetScrollViewContentInset()
        case .Triggered:
            break
        case .Loading:
            self.setScrollViewContentInsetForLoading()
        }
    }
    
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
    
    func updateStateWithNewOffsetY(offsetY: CGFloat) {
        var scrollOffsetThreshold: CGFloat = self.scrollViewOriginalTopInset + pullToRefreshTreschold
        let dragging = self.scrollView.dragging
            if self.state == .Loading {
                return
            }
        if !dragging && self.state == .Triggered {
            if self.highlightedActionViewType == .Center {
                self.state = .Loading
            }
            else {
                self.state = .Stopped
            }
            if let highlightedActionViewType = self.highlightedActionViewType {
                if let actionBlock = self.delegate!.chromePullToRefresh(self, actionForViewWithType: highlightedActionViewType) {
                    actionBlock()
                }
            }
        }
        else if offsetY < scrollOffsetThreshold && dragging && self.state == .Stopped {
            self.state = .Triggered
        }
        else if offsetY >= scrollOffsetThreshold && self.state != .Stopped {
            self.state = .Stopped
        }
    }
    
    //MARK: - Gestures
    
    private var i = 0
    func handleScrollViewPanGesture(panGesture: UIPanGestureRecognizer) {
        if !self.isPanGestureHandlerAdded || self.state == .Loading {
            return
        }
        
        let currentX = panGesture.locationInView(self.pullToRefreshSuperview).x
        let delta = currentX - self.pullToRefreshStartPanGestureX
        self.pullToRefreshView.updateUIWithXDelta(delta)
    }
    
    //MARK: - KVO
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        if context != &self.context {
            return
        }
        if self.state == .Loading {
            return
        }
        
        let newOffsetY = self.scrollView.contentOffset.y
        self.updateViewsWithNewOffsetY(newOffsetY)
        self.updateStateWithNewOffsetY(newOffsetY)
        self.lastObservedOffsetY = newOffsetY
    }
    
    //MARK: - UI
    
    func createPullToRefreshView() {
        self.pullToRefreshView = ADChromePullToRefreshView(frame: self.topView.bounds, delegate: self)
        self.pullToRefreshSuperview.addSubview(self.pullToRefreshView)
    }
}
