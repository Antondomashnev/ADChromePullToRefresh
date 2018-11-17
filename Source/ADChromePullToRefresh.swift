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
    func chromePullToRefresh(_ pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
    func chromePullToRefresh(_ pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction?
}


public class ADChromePullToRefresh: NSObject, ADChromePullToRefreshViewDelegate {
    
    weak var delegate: ADChromePullToRefreshDelegate!
    
    fileprivate var state: ADChromePullToRefreshState = ADChromePullToRefreshState.stopped {
        didSet {
            if self.highlightedActionViewType == .center {
                self.updateForState(self.state)
            }
        }
    }
    
    fileprivate var highlightedActionViewType: ADChromePullToRefreshActionViewType?
    
    fileprivate let scrollViewOriginalTopInset: CGFloat
    fileprivate let scrollViewOriginalOffsetY: CGFloat
    fileprivate let scrollViewOffsetYDeltaForOneAlpha: CGFloat = 60
    fileprivate let scrollViewOffsetYDeltaForTopViewZeroAlpha: CGFloat = 15
    fileprivate let pullToRefreshTreschold: CGFloat = -70.0
    
    fileprivate var context = "com.antondomashnev.ADChromePullToRefresh.KVOContext"
    fileprivate var isObserved: Bool = false
    fileprivate var isPanGestureHandlerAdded: Bool = false
    
    fileprivate var pullToRefreshStartPanGestureX: CGFloat = 0.0
    fileprivate var pullToRefreshScrollProgress: CGFloat = 0.0 {
        didSet {
            if self.pullToRefreshScrollProgress >= 1.0 {
                if !self.isPanGestureHandlerAdded {
                    self.isPanGestureHandlerAdded = true
                    self.pullToRefreshStartPanGestureX = self.scrollView.panGestureRecognizer.location(in: self.pullToRefreshSuperview).x
                    self.scrollView.panGestureRecognizer.addTarget(self, action: #selector(ADChromePullToRefresh.handleScrollViewPanGesture(_:)))
                }
            }
            else {
                if self.isPanGestureHandlerAdded {
                    self.isPanGestureHandlerAdded = false
                    self.pullToRefreshStartPanGestureX = 0.0
                    self.scrollView.panGestureRecognizer.removeTarget(self, action: #selector(ADChromePullToRefresh.handleScrollViewPanGesture(_:)))
                }
            }
        }
    }
    fileprivate var pullToRefreshView: ADChromePullToRefreshView!
    fileprivate var pullToRefreshViewHeightConstraint: NSLayoutConstraint!
    
    fileprivate weak var scrollView: UIScrollView!
    fileprivate weak var topView: UIView!
    fileprivate weak var pullToRefreshSuperview: UIView!
    
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
    
    public func chromePullToRefreshViewDidChangeHighlightedView(_ newHighlightedActionViewType: ADChromePullToRefreshActionViewType?) {
        self.pullToRefreshStartPanGestureX = self.scrollView.panGestureRecognizer.location(in: self.pullToRefreshSuperview).x
        self.highlightedActionViewType = newHighlightedActionViewType
    }
    
    public func chromePullToRefreshView(_ view: ADChromePullToRefreshView, actionViewWithType type: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView {
        return self.delegate!.chromePullToRefresh(self, viewWithType: type)
    }
    
    //MARK: - Interface
    
    func completePullToRefresh() {
        if self.state != .loading {
            return
        }
        self.state = .stopped
    }
    
    func setUpConstraints() {
        let viewsDictionary: [String : ADChromePullToRefreshView] = ["pullToRefresh" : self.pullToRefreshView]
        let horizontalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "H:|[pullToRefresh]|", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.pullToRefreshSuperview.addConstraints(horizontalConstraints)
        let verticalConstraints: [NSLayoutConstraint] = NSLayoutConstraint.constraints(withVisualFormat: "V:|[pullToRefresh]", options: NSLayoutConstraint.FormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.pullToRefreshSuperview.addConstraints(verticalConstraints)
        
        self.pullToRefreshViewHeightConstraint = NSLayoutConstraint(item: self.pullToRefreshView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: self.topView.bounds.height)
        self.pullToRefreshView.addConstraint(self.pullToRefreshViewHeightConstraint)
        
        self.pullToRefreshSuperview.layoutIfNeeded()
        self.pullToRefreshView.setUpConstraints()
    }
    
    //MARK: - Helpers
    
    func setScrollViewContentInset(_ contentInset: UIEdgeInsets, scrollView: UIScrollView) {
        let currentOffsetY = scrollView.contentOffset.y
        let temporaryOffsetY = currentOffsetY + scrollView.contentInset.top
        let offsetX = scrollView.contentOffset.x
        scrollView.setContentOffset(CGPoint(x: offsetX, y: temporaryOffsetY), animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
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
        currentInsets.top = min(offset, self.scrollViewOriginalTopInset + self.pullToRefreshView.bounds.height)
        self.setScrollViewContentInset(currentInsets, scrollView: self.scrollView)
    }
    
    func updateForState(_ newState: ADChromePullToRefreshState) {
        switch state {
        case .stopped:
            self.resetScrollViewContentInset()
        case .triggered:
            break
        case .loading:
            self.setScrollViewContentInsetForLoading()
        }
    }
    
    func subscribeOnScrollViewContentOffset() {
        if self.isObserved {
            return
        }
        self.scrollView.addObserver(self, forKeyPath: "contentOffset", options: .new, context: &context)
    }
    
    func unsubscribeFromScrollViewContentOffset() {
        if !self.isObserved {
            return
        }
        self.scrollView.removeObserver(self, forKeyPath: "contentOffset", context: &context)
    }
    
    func updateViewsWithNewOffsetY(_ offsetY: CGFloat) {
        if offsetY >= self.scrollViewOriginalOffsetY {
            self.topView.alpha = 1
            self.pullToRefreshView.alpha = 0
            self.pullToRefreshViewHeightConstraint.constant = self.topView.bounds.height
            return
        }
        
        let delta = (abs(offsetY) - self.scrollViewOriginalOffsetY)
        let topViewCoefficient = delta / scrollViewOffsetYDeltaForTopViewZeroAlpha
        let newTopViewAlpha = max(0, 1 - topViewCoefficient)
        self.topView.alpha = newTopViewAlpha
        
        self.pullToRefreshScrollProgress = min(1, max(0, (delta - scrollViewOffsetYDeltaForTopViewZeroAlpha) / scrollViewOffsetYDeltaForOneAlpha))
        self.pullToRefreshView.updateUIWithScrollProgress(self.pullToRefreshScrollProgress)
        
        let newPullToRefreshHeight = delta + self.topView.bounds.height
        self.pullToRefreshViewHeightConstraint.constant = newPullToRefreshHeight
    }
    
    func updateStateWithNewOffsetY(_ offsetY: CGFloat) {
        let scrollOffsetThreshold: CGFloat = self.scrollViewOriginalTopInset + pullToRefreshTreschold
        let dragging = self.scrollView.isDragging
            if self.state == .loading {
                return
            }
        if !dragging && self.state == .triggered {
            if self.highlightedActionViewType == .center {
                self.state = .loading
            }
            else {
                self.state = .stopped
            }
            if let highlightedActionViewType = self.highlightedActionViewType {
                if let actionBlock = self.delegate!.chromePullToRefresh(self, actionForViewWithType: highlightedActionViewType) {
                    actionBlock()
                }
            }
        }
        else if offsetY < scrollOffsetThreshold && dragging && self.state == .stopped {
            self.state = .triggered
        }
        else if offsetY >= scrollOffsetThreshold && self.state != .stopped {
            self.state = .stopped
        }
    }
    
    //MARK: - Gestures
    
    fileprivate var i = 0

    @objc func handleScrollViewPanGesture(_ panGesture: UIPanGestureRecognizer) {
        if !self.isPanGestureHandlerAdded || self.state == .loading {
            return
        }
        
        let currentX = panGesture.location(in: self.pullToRefreshSuperview).x
        let delta = currentX - self.pullToRefreshStartPanGestureX
        self.pullToRefreshView.updateUIWithXDelta(delta)
    }
    
    //MARK: - KVO
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context != &self.context {
            return
        }
        if self.state == .loading {
            return
        }
        
        let newOffsetY = self.scrollView.contentOffset.y
        self.updateViewsWithNewOffsetY(newOffsetY)
        self.updateStateWithNewOffsetY(newOffsetY)
    }
    
    //MARK: - UI
    
    func createPullToRefreshView() {
        self.pullToRefreshView = ADChromePullToRefreshView(frame: self.topView.bounds, delegate: self)
        self.pullToRefreshSuperview.addSubview(self.pullToRefreshView)
    }
}
