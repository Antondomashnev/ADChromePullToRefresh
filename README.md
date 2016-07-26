# ADChromePullToRefresh

[![CocoaPods Compatible](https://img.shields.io/cocoapods/v/ADChromePullToRefresh.svg)](https://img.shields.io/cocoapods/v/ADChromePullToRefresh.svg)

Yet another custom pull to refresh for your needs.

Inspired by Google Chrome iOS app

<img src="https://d13yacurqjgara.cloudfront.net/users/21258/screenshots/2022862/attachments/357920/animation.gif" width="320" /> <img src="https://api.monosnap.com/rpc/file/download?id=AHmJeQQnGDwLLBCno9PmY2B73ypiSe" width="320" />

## Easy to use

You can simply setup your own chrome style pull to refresh using the initializer below

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

To provide custom handler for pull to refresh actions you need to implement this delegate methos in your class

```swift
/*
 * Use this function to provide an action for the given action view type
 */
func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, actionForViewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshAction?
```

You're able to customize pull to refresh action view according to your needs 🚀

```swift
/*
 * Use this function to create view with icon for the given pullToRefresh. To customize view use subclass of   
 * ADChromePullToRefreshActionView
 * @see ADChromePullToRefreshActionView.swift
 * @see UITableViewDelegate - similar method to get header and footer view
 */
func chromePullToRefresh(pullToRefresh: ADChromePullToRefresh, viewWithType: ADChromePullToRefreshActionViewType) -> ADChromePullToRefreshActionView
```

## Easy to install

### CocoaPods

To integrate ADPuzzleAnimation into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ADChromePullToRefresh', '~> 0.5'
