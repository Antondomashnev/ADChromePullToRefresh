//
//  ADChromePullToRefreshRightActionView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

public class ADChromePullToRefreshRightActionView: ADChromePullToRefreshActionView {
    
    fileprivate let zeroAlphaScrollProgress: CGFloat = 0.6
    fileprivate let oneAlphaScrollProgress: CGFloat = 0.9
    fileprivate let initialTranslateX: CGFloat = -40.0
    
    //MARK: - Interface
    
    override func updateWithScrollProgress(_ scrollProgress: CGFloat) {
        let newAlpha = min(1, (scrollProgress - zeroAlphaScrollProgress) / (oneAlphaScrollProgress - zeroAlphaScrollProgress))
        self.alpha = newAlpha
        
        let newTranslateX = initialTranslateX - (initialTranslateX * scrollProgress)
        self.iconView.transform = CGAffineTransform.identity.translatedBy(x: newTranslateX, y: 0)
    }
    
    class func rightActionView() -> ADChromePullToRefreshRightActionView {
        let view = ADChromePullToRefreshRightActionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.iconMaskView.image = UIImage(named: "ic_close_black")
        view.iconView.transform = CGAffineTransform.identity.translatedBy(x: view.initialTranslateX, y: 0)
        return view
    }
}
