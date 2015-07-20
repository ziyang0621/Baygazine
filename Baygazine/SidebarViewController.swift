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
    
    func setupScrollView() {
        scrollView = UIScrollView()
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.clipsToBounds = false
        scrollView.showsHorizontalScrollIndicator = false
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
    }
    
    func leftMenuIsOpen() -> Bool {
        return scrollView.contentOffset.x == 0
    }
    
    func rightMenuIsOpen() -> Bool {
        return scrollView.contentOffset.x == CGRectGetWidth(scrollView.frame) * 2
    }
    
    func openLeftMenuAnimated(animated: Bool) {
        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
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
}

extension SidebarViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        let tapLocation = touch.locationInView(view)
        let tapWasInRightOverlapArea = tapLocation.x >= CGRectGetWidth(view.bounds) - overlap
        let tapWasInLeftOverlapArea = tapLocation.x <= overlap
        
        return
            (tapWasInRightOverlapArea && leftMenuIsOpen()) ||
                (tapWasInLeftOverlapArea && rightMenuIsOpen())
    }
}
