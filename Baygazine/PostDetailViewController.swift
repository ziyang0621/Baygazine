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

private let kHeaderViewHeight: CGFloat = 200.0
private let kBottmPadding: CGFloat = 50.0

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
    var post: Post?
    var thumbnailImage: UIImage?
    var headerViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var didLayoutSubviews = false
    var headerImageViewFrame: CGRect!
    var containerViewFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        headerImageView.clipsToBounds = true
        headerImageViewFrame = headerImageView.frame
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        containerViewFrame = containerView.frame
        
        println("view did load \(containerView.frame)")
        
        containerHeightLayoutContraint.constant = CGRectGetHeight(view.bounds)
        containerWidthLayoutContraint.constant = CGRectGetWidth(view.bounds)
        
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)
        loadArticle()
    }
    
    deinit {
        scrollView.delegate = nil
        webView.navigationDelegate = nil
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadArticle() {
        if let thumbnailImage = thumbnailImage {
            headerImageView.image = thumbnailImage
        } else {
            headerImageView.image = UIColor.imageWithColor(kThemeColor)
        }
        titleLabel.text = post!.title!
        authorLabel.textColor = kThemeColor
        authorLabel.text = "by \(post!.author!.nickName!)"
        dateLabel.textColor = UIColor.darkGrayColor()
        dateLabel.text = post!.createdDate!
        
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
        view.bringSubviewToFront(webView)
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
        if didLayoutSubviews {
            updateHeaderImageView()
        }
    }
}

