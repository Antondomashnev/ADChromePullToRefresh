//
//  ViewController.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/18/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ADChromePullToRefreshDelegate {
    
    @IBOutlet fileprivate var tableView: UITableView!
    @IBOutlet fileprivate var topView: UIView!
    
    fileprivate var pullToRefresh: ADChromePullToRefresh!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.topView.translatesAutoresizingMaskIntoConstraints = false
        self.addPullToRefresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setUpConstraints()
    }
    
    //MARK: - Helpers
    
    func setUpConstraints() {
        self.pullToRefresh.setUpConstraints()
    }
    
    func triggerPullToRefresh() -> Void {
        print("center action handled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
    
    func chromePullToRefresh(_ pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView {
        switch viewWithType {
        case .center: return ADChromePullToRefreshCenterActionView.centerActionView()
        case .left: return ADChromePullToRefreshLeftActionView.leftActionView()
        case .right: return ADChromePullToRefreshRightActionView.rightActionView()
        }
    }
    
    func chromePullToRefresh(_ pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction? {
        
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
        case .center: return centerAction
        case .left: return leftAction
        case .right: return rightAction
        }
    }

    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellIdentifier")
        }
        cell?.textLabel?.text = "Title"
        return cell!
    }
}

