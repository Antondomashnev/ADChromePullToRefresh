# ADChromePullToRefresh
Yet another custom pull to refresh for your needs.

Inspire by this dribble and Google Chrome iOS app

<img src="https://d13yacurqjgara.cloudfront.net/users/21258/screenshots/2022862/attachments/357920/animation.gif" width="320" /> <img src="http://i.imgur.com/ofGGbQs.gif" width="320" />

-----
Usage
=====

For the example of usage see viewController.swift file in demo project

```swift
/*
 * To initialize ADChromePullToRefresh use this designated initializer
 * @param view - view to overlay by pull to refresh
 * @param scrollView - for which scrollView we add pull to refresh
 * @param scrollViewOriginalOffsetY - initial offset y of the given scrollView
 * @param delegate - object conformed to ADChromePullToRefreshDelegate protocol
 */
init(view: UIView, forScrollView scrollView: UIScrollView, scrollViewOriginalOffsetY: CGFloat, delegate: ADChromePullToRefreshDelegate) 
```

```swift
//Delegate object must implement two functions

/*
 * Use this function to provide and action for the given action view type
 */
func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction?

/*
 * Use this function to create view with icon for the given pullToRefresh. To customize view use subclass of   
 * ADChromePullToRefreshActionView
 * @see ADChromePullToRefreshActionView.swift
 * @see UITableViewDelegate - similar method to get header and footer view
 */
func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
```
