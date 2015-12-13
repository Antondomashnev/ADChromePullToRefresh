//
//  ADChromePullToRefreshActionView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ADChromePullToRefreshActionView: UIView {

    var iconView: UIView!
    var iconMaskView: UIImageView!
    
    private var highlighted: Bool! = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addIconView()
        self.createIconMaskView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.iconMaskView.frame = self.bounds
        self.iconView.maskView = self.iconMaskView
    }
    
    //MARK: - UI
    
    private func createIconMaskView() {
        self.iconMaskView = UIImageView(frame: self.bounds)
        self.iconMaskView.contentMode = .ScaleAspectFill
    }
    
    private func addIconView() {
        self.iconView = UIView(frame: self.bounds)
        self.iconView.backgroundColor = UIColor.blackColor()
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.iconView)
    }
    
    //MARK: - Interface
    
    func updateWithScrollProgress(scrollProgress: CGFloat) {
        //to override
    }
    
    func isHighlighted() -> Bool {
        return self.highlighted
    }
    
    func setHighighted(highlighted: Bool) {
        if self.highlighted == highlighted {
            return
        }
        
        self.highlighted = highlighted
        if highlighted {
            UIView.animateWithDuration(0.15, animations: { () in
                self.iconView.backgroundColor = UIColor.whiteColor()
            })
        }
        else {
            UIView.animateWithDuration(0.15, animations: { () in
                self.iconView.backgroundColor = UIColor.blackColor()
            })
        }
    }

    func setUpConstraints() {
        let viewsDictionary = ["iconView" : self.iconView]
        let horizontalConstraints: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("H:|[iconView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(horizontalConstraints as! [NSLayoutConstraint])
        let verticalConstraints: NSArray = NSLayoutConstraint.constraintsWithVisualFormat("V:|[iconView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: viewsDictionary)
        self.addConstraints(verticalConstraints as! [NSLayoutConstraint])
    }
}
