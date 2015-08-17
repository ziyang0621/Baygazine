//
//  SidebarViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//
//  This SidebarViewController is modified from the http://www.raywenderlich.com 's scroll view tutorial.
//  Please visit http://www.raywenderlich.com/video-tutorials#swiftscrollview for more details.

import UIKit

class SidebarViewController: UIViewController {
    var leftViewController: UIViewController!
    var mainViewController: UIViewController!
    
    var overlap: CGFloat!
    var scrollView: UIScrollView!
    var firstTime = true
    var viewDidAppear = false
    
    required init(coder aDecoder: NSCoder) {
        assert(false, "Use init(leftViewController:mainViewController:overlap:)")
        super.init(coder: aDecoder)
    }

    init(leftViewController: UIViewController, mainViewController: UIViewController, overlap: CGFloat) {
        self.leftViewController = leftViewController
        self.mainViewController = mainViewController
        self.overlap = overlap
        
        super.init(nibName: nil, bundle: nil)
        
        self.view.backgroundColor = UIColor.blackColor()
        
        setupScrollView()
        setupViewControllers()
    }
    
    override func viewDidLayoutSubviews() {
        if firstTime {
            firstTime = false
            closeMenuAnimated(false)
        }
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
        println("side bar vc did appear")
    }
    
    deinit {
        scrollView.delegate = nil
    }
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.setTranslatesAutoresizingMaskIntoConstraints(false)
        view.addSubview(scrollView)
        
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -overlap)
        
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|[scrollView]", options: nil, metrics: nil, views: ["scrollView": scrollView])
        let scrollWidthConstraint = NSLayoutConstraint(
            item: scrollView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0, constant: -overlap)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[scrollView]|", options: nil, metrics: nil, views: ["scrollView": scrollView])
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints + [scrollWidthConstraint])
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "viewTapped:")
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    func viewTapped(tapRecognizer: UITapGestureRecognizer) {
        closeMenuAnimated(true)
    }
    
    func setupViewControllers() {
        addViewController(leftViewController)
        addViewController(mainViewController)

        addShadowToView(mainViewController.view)
        
        let views = ["left": leftViewController.view, "main": mainViewController.view, "outer": view]
        let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "|[left][main(==outer)]|", options: .AlignAllTop | .AlignAllBottom, metrics: nil, views: views)
        let leftWidthConstraint = NSLayoutConstraint(
            item: leftViewController.view,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: view,
            attribute: .Width,
            multiplier: 1.0, constant: -overlap)
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|[main(==outer)]|", options: nil, metrics: nil, views: views)
        NSLayoutConstraint.activateConstraints(horizontalConstraints + verticalConstraints + [leftWidthConstraint])
        
        view.addGestureRecognizer(scrollView.panGestureRecognizer)
    }
    
    func closeMenuAnimated(animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: CGRectGetWidth(scrollView.frame), y: 0), animated: animated)
        setToPercent(0)
    }
    
    func leftMenuIsOpen() -> Bool {
        return scrollView.contentOffset.x == 0
    }
    
    func openLeftMenuAnimated(animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
        setToPercent(1)
    }
    
    func toggleLeftMenuAnimated(animated: Bool) {
        if leftMenuIsOpen() {
            closeMenuAnimated(animated)
        } else {
            openLeftMenuAnimated(animated)
        }
        
    }
    
    private func addViewController(viewController: UIViewController) {
        viewController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
        scrollView.addSubview(viewController.view)
        addChildViewController(viewController)
        viewController.didMoveToParentViewController(self)
    }
    
    private func addShadowToView(destView: UIView) {
        destView.layer.shadowPath = UIBezierPath(rect: destView.bounds).CGPath
        destView.layer.shadowRadius = 2.5
        destView.layer.shadowOffset = CGSize(width: 0, height: 0)
        destView.layer.shadowOpacity = 1.0
        destView.layer.shadowColor = UIColor.blackColor().CGColor
    }
    
    private func setToPercent(percent: CGFloat) {
        
        let vc = (mainViewController as! UINavigationController).viewControllers.first as! UIViewController
        
        if vc.isKindOfClass(NewsListViewController) {
            if let menuButton =  (vc as! NewsListViewController).menuButton {
                menuButton.imageView.layer.transform = buttonTransformForPercent(percent)
            }
        } else if vc.isKindOfClass(AboutViewController) {
            if let menuButton =  (vc as! AboutViewController).menuButton {
                menuButton.imageView.layer.transform = buttonTransformForPercent(percent)
            }
        }
    }
    
    
    private func buttonTransformForPercent(percent: CGFloat) -> CATransform3D {
        
        var identity = CATransform3DIdentity
        identity.m34 = -1.0/1000
        
        let angle = percent * CGFloat(-M_PI)
        let rotationTransform = CATransform3DRotate(identity, angle, 1.0, 1.0, 0.0)
        
        return rotationTransform
    }
    
    func enableHorizontalScrolling() {
        scrollView.contentSize = CGSize(width: CGRectGetWidth(leftViewController.view.bounds) + CGRectGetWidth(mainViewController.view.bounds), height: CGRectGetHeight(scrollView.bounds))
        scrollView.contentOffset = CGPoint(x: CGRectGetWidth(scrollView.frame), y: 0)
    }
    
    func disableHorizontalScrolling() {
        scrollView.contentSize = CGSize(width: CGRectGetWidth(view.bounds), height: CGRectGetHeight(scrollView.bounds))
        scrollView.contentOffset = CGPoint(x: CGRectGetWidth(scrollView.frame), y: 0)
    }
}

extension SidebarViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if viewDidAppear {
            let width = CGRectGetWidth(leftViewController.view.frame)
            let percent = (scrollView.contentOffset.x - width) / width
            setToPercent(percent)
        }
    }
}

extension SidebarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let tapLocation = touch.locationInView(view)
        let tapWasInRightOverlapArea = tapLocation.x >= CGRectGetWidth(view.bounds) - overlap
        
        return (tapWasInRightOverlapArea && leftMenuIsOpen())
    }
}
