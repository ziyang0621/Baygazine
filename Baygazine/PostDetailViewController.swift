//
//  PostDetailViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import KVNProgress
import WebKit

private let kHeaderViewHeight: CGFloat = 300.0
private let kBottmPadding: CGFloat = 100.0

class PostDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var webViewContainerHeightLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var containerHeightLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var containerWidthLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var webViewContainer: UIView!
    var webView: WKWebView!
    var blurViewContainer: UIView!
    var post: Post?
    var thumbnailImage: UIImage?
    var headerViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var didLayoutSubviews = false
    var headerImageViewFrame: CGRect!
    var containerViewFrame: CGRect!
    var navBarHeight: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        headerImageView.clipsToBounds = true
        headerImageViewFrame = headerImageView.frame
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        containerViewFrame = containerView.frame
        containerHeightLayoutContraint.constant = CGRectGetHeight(view.bounds)
        containerWidthLayoutContraint.constant = CGRectGetWidth(view.bounds)
        navBarHeight = CGRectGetHeight(navigationController!.navigationBar.frame)
        
        KVNProgress.showWithStatus("讀取中...", onView: navigationController?.view)
        
        loadArticle()
    }
    
    deinit {
        scrollView.delegate = nil
        webView.navigationDelegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setupBlurView() {
        blurViewContainer = UIView(frame: CGRectZero)
        blurViewContainer.backgroundColor = UIColor.clearColor()
        headerImageView.addSubview(blurViewContainer)
        blurViewContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        let blurViewContainerTopContraint = NSLayoutConstraint(item: blurViewContainer, attribute: .Top, relatedBy: .Equal, toItem: headerImageView, attribute: .Top, multiplier: 1, constant: 0)
        let blurViewwContainerBottomContraint = NSLayoutConstraint(item: blurViewContainer, attribute: .Bottom, relatedBy: .Equal, toItem: headerImageView, attribute: .Bottom, multiplier: 1, constant: 0)
        let blurViewwContainerLeftContraint = NSLayoutConstraint(item: blurViewContainer, attribute: .Left, relatedBy: .Equal, toItem: headerImageView, attribute: .Left, multiplier: 1, constant: 0)
        let blurViewwContainerRightContraint = NSLayoutConstraint(item: blurViewContainer, attribute: .Right, relatedBy: .Equal, toItem: headerImageView, attribute: .Right, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([blurViewContainerTopContraint, blurViewwContainerBottomContraint, blurViewwContainerLeftContraint, blurViewwContainerRightContraint])
        
        let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .Light)) as UIVisualEffectView
        blurViewContainer.addSubview(blurView)
        blurView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let blurViewTopContraint = NSLayoutConstraint(item: blurView, attribute: .Top, relatedBy: .Equal, toItem: blurViewContainer, attribute: .Top, multiplier: 1, constant: 0)
        let blurViewBottomContraint = NSLayoutConstraint(item: blurView, attribute: .Bottom, relatedBy: .Equal, toItem: blurViewContainer, attribute: .Bottom, multiplier: 1, constant: 0)
        let blurViewLeftContraint = NSLayoutConstraint(item: blurView, attribute: .Left, relatedBy: .Equal, toItem: blurViewContainer, attribute: .Left, multiplier: 1, constant: 0)
        let blurViewRightContraint = NSLayoutConstraint(item: blurView, attribute: .Right, relatedBy: .Equal, toItem: blurViewContainer, attribute: .Right, multiplier: 1, constant: 0)
        NSLayoutConstraint.activateConstraints([blurViewTopContraint, blurViewBottomContraint, blurViewLeftContraint, blurViewRightContraint])
    }
    
    func setupWebview() {
        webView = WKWebView(frame: CGRectZero)
        webViewContainer.addSubview(webView)
        webView.navigationDelegate = self
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: webViewContainer, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: webView, attribute: .Bottom, relatedBy: .Equal, toItem: webViewContainer, attribute: .Bottom, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: webViewContainer, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: webViewContainer, attribute: .Right, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([topConstraint, bottomConstraint, leftConstraint, rightConstraint])
        
        let styleString = "<style>iframe{width:100%} img{width:100%;pointer-events:none;cursor:default} body{font-size:200%}</style>"
        webView.loadHTMLString(styleString + post!.content! + post!.excerpt!, baseURL: nil)
    }
    
    func loadArticle() {
        titleLabel.text = post!.title!
        authorLabel.textColor = kThemeColor
        authorLabel.text = "by \(post!.author!.nickName!)"
        dateLabel.textColor = UIColor.darkGrayColor()
        dateLabel.text = post!.createdDate!
        
        if let thumbnailImage = thumbnailImage {
            headerImageView.image = thumbnailImage
        } else {
            headerImageView.image = UIColor.imageWithColor(kThemeColor)
        }
        setupBlurView()
        
        setupWebview()
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("did layout")
        didLayoutSubviews = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        println("did appear")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateHeaderImageView() {
        let insets = scrollView.contentInset
        let offset = scrollView.contentOffset
        let minY = -insets.top
        if offset.y < minY {
            let deltaY = fabs(offset.y - minY)
            var frame = headerImageViewFrame
            frame.size.height = min(max(minY, kHeaderViewHeight + deltaY), maximumStretchHeight!)
            frame.origin.y = CGRectGetMinY(frame) - deltaY
            headerImageViewTopLayoutContraint.constant = frame.origin.y
            headerImageViewHeightLayoutConstraint.constant = frame.size.height
        }
    }
    
    func updateWebview() {
        webViewContainerHeightLayoutContraint.constant = webView.scrollView.contentSize.height
        
        if webView.scrollView.contentSize.height + kHeaderViewHeight + kBottmPadding > self.view.bounds.height {
            scrollView.contentSize.height = webView.scrollView.contentSize.height + kHeaderViewHeight + kBottmPadding
            containerHeightLayoutContraint.constant = scrollView.contentSize.height
        }
        
        println("update \(containerView.frame) ")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
           self.updateWebview()
           self.containerWidthLayoutContraint.constant = CGRectGetWidth(self.view.bounds)
        }, completion: nil)
    }
    
    func checkWebViewDidFinish() {
        if webView.scrollView.contentSize.height == 0 {
            let time = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * 1.0))
            
            dispatch_after(time, dispatch_get_main_queue()) {
                self.webView(self.webView, didFinishNavigation: nil)
            }
        }
    }
}

extension PostDetailViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if webView.scrollView.contentSize.height == 0 {
            checkWebViewDidFinish()
        } else {
            updateWebview()
            KVNProgress.dismiss()
        }
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        println("did scroll: \(scrollView.contentInset.top) \(scrollView.contentOffset.y)")
        if scrollView.contentOffset.y > 0 {
            let percent: CGFloat = fabs(scrollView.contentOffset.y / (kHeaderViewHeight - navBarHeight))
            println("percent \(percent)")
            blurViewContainer.alpha = percent * 3
        } else {
            blurViewContainer.alpha = 0
        }
        if didLayoutSubviews {
            updateHeaderImageView()
        }
    }
}

