//
//  ViewController.swift
//  ADChromePullToRefresh
//
//  Created by Anton Domashnev on 4/18/15.
//  Copyright (c) 2015 Anton Domashnev. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var topView: UIView!
    
    private var pullToRefresh: ADChromePullToRefresh!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.topView.setTranslatesAutoresizingMaskIntoConstraints(false)
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
    
    //MARK: - ADChromePullToRefresh
    
    func addPullToRefresh() {
        let centerActionHandler: () -> Void = { () in
            let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(3 * Double(NSEC_PER_SEC)))
            dispatch_after(delayTime, dispatch_get_main_queue()) {
                self.pullToRefresh.completePullToRefresh()
            }
        }
        
        self.pullToRefresh = ADChromePullToRefresh(view: self.topView, topViewOriginalAlpha: 1, forScrollView: self.tableView, scrollViewOriginalOffsetY: 0, leftActionHandler: nil, centerActionHandler: centerActionHandler)
    }

    //MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier("cellIdentifier") as? UITableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "cellIdentifier")
        }
        cell?.textLabel?.text = "Title"
        return cell!
    }
}

