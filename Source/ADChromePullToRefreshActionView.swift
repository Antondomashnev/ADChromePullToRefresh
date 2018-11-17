//
//  ADChromePullToRefreshActionView.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/26/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

public class ADChromePullToRefreshActionView: UIView {

    var iconView: UIView!
    var iconMaskView: UIImageView!
    
    fileprivate var highlighted: Bool! = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        self.addIconView()
        self.createIconMaskView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIView
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        self.iconMaskView.frame = self.bounds
        self.iconView.mask = self.iconMaskView
    }
    
    //MARK: - UI
    
    fileprivate func createIconMaskView() {
        self.iconMaskView = UIImageView(frame: self.bounds)
        self.iconMaskView.contentMode = .scaleAspectFill
    }
    
    fileprivate func addIconView() {
        self.iconView = UIView(frame: self.bounds)
        self.iconView.backgroundColor = UIColor.black
        self.iconView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.iconView)
    }
    
    //MARK: - Interface
    
    func updateWithScrollProgress(_ scrollProgress: CGFloat) {
        //to override
    }
    
    func isHighlighted() -> Bool {
        return self.highlighted
    }
    
    func setHighighted(_ highlighted: Bool) {
        if self.highlighted == highlighted {
            return
        }
        
        self.highlighted = highlighted
        if highlighted {
            UIView.animate(withDuration: 0.15, animations: { () in
                self.iconView.backgroundColor = UIColor.white
            })
        }
        else {
            UIView.animate(withDuration: 0.15, animations: { () in
                self.iconView.backgroundColor = UIColor.black
            })
        }
    }

    func setUpConstraints() {
        let viewsDictionary: [String : UIView] = ["iconView" : self.iconView]
        let horizontalConstraints: NSArray = NSLayoutConstraint.constraints(withVisualFormat: "H:|[iconView]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary) as NSArray
        self.addConstraints(horizontalConstraints as! [NSLayoutConstraint])
        let verticalConstraints: NSArray = NSLayoutConstraint.constraints(withVisualFormat: "V:|[iconView]|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: viewsDictionary) as NSArray
        self.addConstraints(verticalConstraints as! [NSLayoutConstraint])
    }
}
