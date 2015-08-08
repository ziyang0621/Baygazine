//
//  ExpandingCellTransition.swift
//  Baygazine
//
//  Created by Ziyang Tan on 8/6/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

private let kExpandingCellTransitionDuration: NSTimeInterval = 0.6

class ExpandingCellTransition: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    enum TransitionType {
        case None
        case Presenting
        case Dismissing
    }
    
    enum TransitionState {
        case Initial
        case Final
    }
    
    var type: TransitionType = .None
    var presentingController: UIViewController!
    var presentedController: UIViewController!
    
    var targetSnapshot: UIView!
    var targetContainer: UIView!
    
    var topRegionSnapshot: UIView!
    var bottomRegionSnapshot: UIView!
    var navigationBarSnapshot: UIView!
    
    func sliceSnapshotsInBackgroundViewController(backgroundViewController: UIViewController, targetFrame: CGRect, targetView: UIView) {
        let view = backgroundViewController.view
        let width = view.bounds.width
        let height = view.bounds.height
        
        // create top region snapshot
        topRegionSnapshot = view.resizableSnapshotViewFromRect(CGRect(x: 0, y: 0, width: width, height: targetFrame.minY), afterScreenUpdates: false, withCapInsets: UIEdgeInsetsZero)
        
        // create bottom region snapshot
        bottomRegionSnapshot = view.resizableSnapshotViewFromRect(CGRect(x: 0, y: targetFrame.maxY, width: width, height: height-targetFrame.maxY), afterScreenUpdates: false, withCapInsets: UIEdgeInsetsZero)
        
        // create target view snapshot
        targetSnapshot = targetView.snapshotViewAfterScreenUpdates(true)
        targetContainer = UIView(frame: targetFrame)
        targetContainer.backgroundColor = UIColor.whiteColor()
        targetContainer.clipsToBounds = true
        if targetSnapshot == nil {
            println("emtpy target snap shot")
        }
        targetContainer.addSubview(targetSnapshot)
        
        // create navigation bar snapshot
        if let navController = backgroundViewController as? UINavigationController {
            let barHeight = navController.navigationBar.frame.maxY
            
            UIGraphicsBeginImageContext(CGSize(width: width, height: barHeight))
            view.drawViewHierarchyInRect(view.bounds, afterScreenUpdates: false)
            let navigationBarImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            navigationBarSnapshot = UIImageView(image: navigationBarImage)
            navigationBarSnapshot.backgroundColor = navController.navigationBar.barTintColor
            navigationBarSnapshot.contentMode = .Bottom
        }
    }
    
    func configureViewsToState(state: TransitionState, width: CGFloat, height: CGFloat, targetFrame: CGRect, fullFrame: CGRect, foregroundView: UIView) {
        switch state {
        case .Initial:
            topRegionSnapshot.frame = CGRect(x: 0, y: 0, width: width, height: targetFrame.minY)
            bottomRegionSnapshot.frame = CGRect(x: 0, y: targetFrame.maxY, width: width, height: height-targetFrame.maxY)
            targetContainer.frame = targetFrame
            targetSnapshot.alpha = 1
            foregroundView.alpha = 0
            navigationBarSnapshot.sizeToFit()
            
        case .Final:
            topRegionSnapshot.frame = CGRect(x: 0, y: -targetFrame.minY, width: width, height: targetFrame.minY)
            bottomRegionSnapshot.frame = CGRect(x: 0, y: height, width: width, height: height-targetFrame.maxY)
            targetContainer.frame = fullFrame
            targetSnapshot.alpha = 0
            foregroundView.alpha = 1
        }
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return kExpandingCellTransitionDuration
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        let duration = transitionDuration(transitionContext)
        let fromViewController = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)!
        let toViewController = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)!
        let containerView = transitionContext.containerView()
        
        if let fromVC = fromViewController as? UINavigationController {
            println("is nav")
            if fromVC.topViewController.isKindOfClass(NewsListViewController) {
                println("is news list")
            }
        }
        
        if fromViewController.isKindOfClass(SidebarViewController) {
            println("test side bar")
        }
        
        if fromViewController.isKindOfClass(NewsListViewController) {
            println("test news list")
        }
        
        var foregroundViewController = toViewController
        var backgroundViewController = fromViewController
        
        if type == .Dismissing {
            foregroundViewController = fromViewController
            backgroundViewController = toViewController
        }
        
        containerView.addSubview(backgroundViewController.view)
        containerView.addSubview(foregroundViewController.view)
        
        // get target view
        var targetViewController = backgroundViewController
        
        if let navController = targetViewController as? UINavigationController {
            targetViewController = navController.topViewController
        }
        let targetViewMaybe = (targetViewController as? ExpandingTransitionPresentingViewController)?.expandingTransitionTargetViewForTransition(self)
        
        assert(targetViewMaybe != nil, "Cannot find target view in background view controller")
        
        let targetView = targetViewMaybe!
        
        // setup animation
        let targetFrame = backgroundViewController.view.convertRect(targetView.frame, fromView: targetView.superview)
        if type == .Presenting {
            // workaround when root view controller is SidebarViewController
            if backgroundViewController.isKindOfClass(SidebarViewController) {
                sliceSnapshotsInBackgroundViewController(((backgroundViewController as! SidebarViewController).mainViewController as! UINavigationController), targetFrame: targetFrame, targetView: targetView)
            } else if backgroundViewController.isKindOfClass(NewsListViewController) {
                sliceSnapshotsInBackgroundViewController(backgroundViewController.navigationController!, targetFrame: targetFrame, targetView: targetView)
            } else {
                sliceSnapshotsInBackgroundViewController(backgroundViewController, targetFrame: targetFrame, targetView: targetView)
            }
            (foregroundViewController as? ExpandingTransitionPresentedViewController)?.expandingTransition(self, navigationBarSnapshot: navigationBarSnapshot)
        }
        else {
            navigationBarSnapshot.frame = containerView.convertRect(navigationBarSnapshot.frame, fromView: navigationBarSnapshot.superview)
        }
        
        targetContainer.addSubview(foregroundViewController.view)
        containerView.addSubview(targetContainer)
        containerView.addSubview(topRegionSnapshot)
        containerView.addSubview(bottomRegionSnapshot)
        containerView.addSubview(navigationBarSnapshot)
        
        let width = backgroundViewController.view.bounds.width
        let height = backgroundViewController.view.bounds.height
        
        let preTransition: TransitionState = (type == .Presenting ? .Initial : .Final)
        let postTransition: TransitionState = (type == .Presenting ? .Final : .Initial)
        
        configureViewsToState(preTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)
        
        // perform animation
        backgroundViewController.view.hidden = true
        UIView.animateWithDuration(duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0, options: .allZeros, animations: { () -> Void in
            [self]
            self.configureViewsToState(postTransition, width: width, height: height, targetFrame: targetFrame, fullFrame: foregroundViewController.view.frame, foregroundView: foregroundViewController.view)
            
            if self.type == .Presenting {
                self.navigationBarSnapshot.frame.size.height = 0
            }
            
            }, completion: {
                (finished) in
                [self]
                self.targetContainer.removeFromSuperview()
                self.topRegionSnapshot.removeFromSuperview()
                self.bottomRegionSnapshot.removeFromSuperview()
                self.navigationBarSnapshot.removeFromSuperview()

                containerView.addSubview(foregroundViewController.view)
                backgroundViewController.view.hidden = false
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled())
        })
    }
    
//    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        presentingController = presenting
//        
//        if let navController = presentingController as? UINavigationController {
//            presentingController = navController.topViewController
//        }
//        
//        if presentingController is ExpandingTransitionPresentingViewController {
//            type = .Presenting
//            return self
//        }
//        else {
//            type = .None
//            return nil
//        }
//    }
//    
//    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
//        if presentingController is ExpandingTransitionPresentingViewController {
//            type = .Dismissing
//            return self
//        }
//        else {
//            type = .None
//            return nil
//        }
//    }
    
}

protocol ExpandingTransitionPresentingViewController {
    func expandingTransitionTargetViewForTransition(transition: ExpandingCellTransition) -> UIView!
}

protocol ExpandingTransitionPresentedViewController {
    func expandingTransition(transition: ExpandingCellTransition, navigationBarSnapshot: UIView)
}
