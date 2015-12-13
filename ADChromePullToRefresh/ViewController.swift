//
//  ViewController.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/18/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ADChromePullToRefreshDelegate {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var topView: UIView!
    
    private var pullToRefresh: ADChromePullToRefresh!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpConstraints()
    }
    
    //MARK: - Helpers
    
    func setUpConstraints() {
        self.pullToRefresh.setUpConstraints()
    }
    
    func triggerPullToRefresh() -> Void {
        print("center action handled")
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1.5 * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue()) {
            self.pullToRefresh.completePullToRefresh()
        }
    }
    
    func triggerLeftAction() -> Void {
        print("left action handled")
    }
    
    func triggerRightAction() -> Void {
        print("right action handled")
    }
    
    //MARK: - ADChromePullToRefresh
    
    func addPullToRefresh() {
        self.pullToRefresh = ADChromePullToRefresh(view: self.topView, forScrollView: self.tableView, scrollViewOriginalOffsetY: 0, delegate: self)
    }
    
    //MARK: - ADChromePullToRefreshDelegate
    
    func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView {
        switch viewWithType {
        case .Center: return ADChromePullToRefreshCenterActionView.centerActionView()
        case .Left: return ADChromePullToRefreshLeftActionView.leftActionView()
        case .Right: return ADChromePullToRefreshRightActionView.rightActionView()
        }
    }
    
    func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction? {
        
        let centerAction: ADChromePullToRefreshAction = { () -> Void in
            self.triggerPullToRefresh()
        }
        
        let leftAction: ADChromePullToRefreshAction = { () -> Void in
            self.triggerLeftAction()
        }
        
        let rightAction: ADChromePullToRefreshAction = { () -> Void in
            self.triggerRightAction()
        }

        switch actionForViewWithType {
        case .Center: return centerAction
        case .Left: return leftAction
        case .Right: return rightAction
        }
    }

    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cellIdentifier")
        }
        cell?.textLabel?.text = "Title"
        return cell!
    }
}

