//
//  PostDetailViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import KVNProgress

private let kHeaderViewHeight: CGFloat = 200.0
private let kBottmPadding: CGFloat = 50.0

class PostDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var webViewHeightLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var webView: UIWebView!
    @IBOutlet weak var containerView: UIView!
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
        
        println("view did load: \(webView.scrollView.contentSize.width) \(scrollView.frame)")
        
        KVNProgress.showWithStatus("Loading...", onView: navigationController?.view)
        loadArticle()
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
        webView.delegate = self
        
        let styleString = "<style>iframe {width:100%} img {width:100%;pointer-events: none;cursor: default}</style>"
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
        if scrollView == nil {
            println("nil scrollview")
            return
        }
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
        self.webViewHeightLayoutContraint.constant = self.webView.scrollView.contentSize.height
        
        if self.webView.scrollView.contentSize.height + kHeaderViewHeight + kBottmPadding > self.view.bounds.height {
            self.scrollView.contentSize.height = self.webView.scrollView.contentSize.height + kHeaderViewHeight + kBottmPadding
        }
        webView.stringByEvaluatingJavaScriptFromString("")
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animateAlongsideTransition({ (context) -> Void in
           self.updateWebview()
        }, completion: nil)
    }
}

extension PostDetailViewController: UIWebViewDelegate {
    func webViewDidFinishLoad(webView: UIWebView) {
        println("finish \(webView.scrollView.contentSize.height)")

        updateWebview()
        
        println("webview: \(webView.scrollView.contentSize.width) \(scrollView.frame)")
        KVNProgress.dismiss()
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if didLayoutSubviews {
            updateHeaderImageView()
        }
    }
}

