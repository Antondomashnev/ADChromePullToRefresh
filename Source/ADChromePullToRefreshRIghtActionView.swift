//
//  ADChromePullToRefreshRightActionView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ADChromePullToRefreshRightActionView: ADChromePullToRefreshActionView {
    
    private let zeroAlphaScrollProgress: CGFloat = 0.6
    private let oneAlphaScrollProgress: CGFloat = 0.9
    private let initialTranslateX: CGFloat = -40.0
    
    //MARK: - Interface
    
    override func updateWithScrollProgress(scrollProgress: CGFloat) {
        let newAlpha = min(1, (scrollProgress - zeroAlphaScrollProgress) / (oneAlphaScrollProgress - zeroAlphaScrollProgress))
        self.alpha = newAlpha
        
        let newTranslateX = initialTranslateX - (initialTranslateX * scrollProgress)
        self.iconView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, newTranslateX, 0)
    }
    
    class func rightActionView() -> ADChromePullToRefreshRightActionView {
        let view = ADChromePullToRefreshRightActionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.iconMaskView.image = UIImage(named: "ic_close_black")
        view.iconView.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, view.initialTranslateX, 0)
        return view
    }
}
