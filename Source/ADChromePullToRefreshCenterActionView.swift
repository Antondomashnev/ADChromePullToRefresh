//
//  ADChromePullToRefreshCenterActionView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

public class ADChromePullToRefreshCenterActionView: ADChromePullToRefreshActionView {

    fileprivate let initialIconRotation: CGFloat = (CGFloat)(-Double.pi / 2 + Double.pi / 4)
    fileprivate let zeroAlphaScrollProgress: CGFloat = 0.2
    fileprivate let oneAlphaScrollProgress: CGFloat = 0.9
    
    //MARK: - ADChromePullToRefreshActionView
    
    override func updateWithScrollProgress(_ scrollProgress: CGFloat) {
        let newAngle = self.initialIconRotation + scrollProgress * CGFloat(Double.pi / 2)
        self.iconView.transform = CGAffineTransform.identity.rotated(by: newAngle)
        
        let newAlpha = min(1, (scrollProgress - zeroAlphaScrollProgress) / (oneAlphaScrollProgress - zeroAlphaScrollProgress))
        self.alpha = newAlpha
    }
    
    //MARK: - Interface

    class func centerActionView() -> ADChromePullToRefreshCenterActionView {
        let view = ADChromePullToRefreshCenterActionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        view.iconView.transform = CGAffineTransform.identity.rotated(by: view.initialIconRotation)
        view.iconMaskView.image = UIImage(named: "ic_refresh_black")
        return view
    }
}
