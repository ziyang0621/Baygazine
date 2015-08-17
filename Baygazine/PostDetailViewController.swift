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
import pop
import hpple

private let kHeaderViewHeight: CGFloat = 300.0

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
    var webView: UIWebView!
    var blurViewContainer: UIView!
    var post: Post?
    var thumbnailImage: UIImage?
    var headerViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var viewDidAppear = false
    var headerImageViewFrame: CGRect!
    var containerViewFrame: CGRect!
    var navBarHeight: CGFloat!
    var didLabelAnimatinons = false
    var detailedImages = [PostDetailImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        let leftBarButton = UIBarButtonItem(image: UIImage(named: "IconClose"), style: .Plain, target: self, action: "close")
        navigationItem.leftBarButtonItem = leftBarButton
        
        scrollView.delegate = self
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        containerViewFrame = containerView.frame
        containerHeightLayoutContraint.constant = CGRectGetHeight(view.bounds)
        containerWidthLayoutContraint.constant = CGRectGetWidth(view.bounds)
        navBarHeight = CGRectGetHeight(navigationController!.navigationBar.frame)
        
        loadArticle()
        labelAnimations()
    }
    
    
    override func observeValueForKeyPath(keyPath: String, ofObject object: AnyObject, change: [NSObject : AnyObject], context: UnsafeMutablePointer<Void>) {
        let size = change["new"]!.CGSizeValue()
        updateWebview(size.height)
    }
    
    func close() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    deinit {
        scrollView.delegate = nil
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        (appDelegate.window?.rootViewController as! SidebarViewController).disableHorizontalScrolling()
    }
    
    func setupHeaderImageView() {
        headerImageView.clipsToBounds = true
        headerImageView.backgroundColor = UIColor.colorWithRGBHex(0x4A4A4A, alpha: 0.8)
        headerImageViewFrame = headerImageView.frame

        if let imgURL = post?.thumbnailUrl {
            if let thumbnailImage = thumbnailImage {
                headerImageView.image = thumbnailImage
            } else {
                let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
                headerImageView.addSubview(activityIndicator)
                activityIndicator.center = CGPoint(x: CGRectGetMidX(view.bounds), y: CGRectGetMaxY(navigationController!.navigationBar.bounds) + 100)
                activityIndicator.startAnimating()
                let request = NSURLRequest(URL: NSURL(string: imgURL)!)
                headerImageView.image = nil
                headerImageView.setImageWithURLRequest(request, placeholderImage: nil, success: {
                    (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                    activityIndicator.removeFromSuperview()
                    self.headerImageView.image = image
                    }, failure: nil)
            }
        } else {
            headerImageView.image = UIColor.imageWithColor(kThemeColor)
        }
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
        webView = UIWebView(frame: CGRectZero)
        webViewContainer.addSubview(webView)
        webViewContainer.alpha = 0
        webView.scrollView.scrollEnabled = false
        
        webView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let topConstraint = NSLayoutConstraint(item: webView, attribute: .Top, relatedBy: .Equal, toItem: webViewContainer, attribute: .Top, multiplier: 1, constant: 0)
        let heightConstraint = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: webViewContainer, attribute: .Height, multiplier: 1, constant: 0)
        let leftConstraint = NSLayoutConstraint(item: webView, attribute: .Left, relatedBy: .Equal, toItem: webViewContainer, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: webView, attribute: .Right, relatedBy: .Equal, toItem: webViewContainer, attribute: .Right, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activateConstraints([topConstraint, heightConstraint, leftConstraint, rightConstraint])
        
        webView.scrollView.addObserver(self, forKeyPath: "contentSize", options: .New, context: nil)
        
        var styleString = "<style>iframe{width:100%} img{pointer-events:none;cursor:default;border:1% solid;border-radius:5%;margin:1% 1% 1% 1%} body{font-size:100%;padding:2% 2% 2% 2%}</style>"
        
        var finalString = post!.content!
        
        let matchString = String.matchesForRegexInTextCaptureGroup("(<img .+? \\/>)", text: finalString)
        for match in matchString {
            let detailedImage = PostDetailImage(fullRaw: match)
            detailedImage.updateWidthAndHeightWithDeviceBounds(UIScreen.mainScreen().bounds)
    
            if let raw = detailedImage.raw {
                if let textRange = finalString.rangeOfString(raw, options: .LiteralSearch, range: nil, locale: nil) {
                    if let newRaw = detailedImage.newRaw {
                         finalString = finalString.stringByReplacingOccurrencesOfString(raw, withString: newRaw, options: .LiteralSearch, range: nil)
                    }
                }
            }
        }
        
        let regex = NSRegularExpression(pattern: "<style.*?<\\/style>" , options: .DotMatchesLineSeparators, error: nil)
        if let regex = regex {
            finalString = regex.stringByReplacingMatchesInString(finalString, options: nil, range: NSMakeRange(0, count(finalString)), withTemplate: "")
        }
        
        webView.loadHTMLString(styleString + finalString, baseURL: nil)
    }
    
    func loadArticle() {
        titleLabel.text = post!.title!
        titleLabel.layer.opacity = 0
        authorLabel.textColor = kThemeColor
        authorLabel.text = "by \(post!.author!.name!)"
        authorLabel.layer.opacity = 0
        dateLabel.textColor = UIColor.darkGrayColor()
        dateLabel.text = post!.createdDate!
        dateLabel.layer.opacity = 0
        
        setupHeaderImageView()
        
        setupBlurView()
        
        setupWebview()
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewDidAppear = true
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
    
    func updateWebview(height: CGFloat) {
        webViewContainerHeightLayoutContraint.constant = height
        scrollView.contentSize.height = height + kHeaderViewHeight + CGRectGetHeight(navigationController!.view.bounds)
        containerHeightLayoutContraint.constant = scrollView.contentSize.height
        
        view.updateConstraints()
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.webViewContainer.alpha = 1
        })
    }
    
    func labelAnimations() {
        
        if !didLabelAnimatinons {
            let titleGroup = CAAnimationGroup()
            titleGroup.beginTime = CACurrentMediaTime() + 0.3
            titleGroup.duration = 0.5
            titleGroup.fillMode = kCAFillModeBackwards
            titleGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
            
            let scaleDown = CABasicAnimation(keyPath: "transform.scale")
            scaleDown.fromValue = 5.0
            scaleDown.toValue = 1.0
            
            let fade = CABasicAnimation(keyPath: "opacity")
            fade.fromValue = 0.0
            fade.toValue = 1.0
            
            titleGroup.animations = [scaleDown, fade]
            titleLabel.layer.addAnimation(titleGroup, forKey: nil)
            titleLabel.layer.opacity = 1
            
            let labelGroup = CAAnimationGroup()
            labelGroup.duration = 0.5
            labelGroup.fillMode = kCAFillModeBackwards
            
            let flyRight = CABasicAnimation(keyPath: "position.x")
            flyRight.fromValue = -view.bounds.size.width/2
            flyRight.toValue = view.bounds.size.width/2
            
            let fadeFieldIn = CABasicAnimation(keyPath: "opacity")
            fadeFieldIn.fromValue = 0.25
            fadeFieldIn.toValue = 1.0
            
            labelGroup.animations = [flyRight, fadeFieldIn]
            
            labelGroup.beginTime = CACurrentMediaTime() + 0.6
            authorLabel.layer.addAnimation(labelGroup, forKey: nil)
            authorLabel.layer.opacity = 1
            
            labelGroup.beginTime = CACurrentMediaTime() + 0.7
            dateLabel.layer.addAnimation(labelGroup, forKey: nil)
            dateLabel.layer.opacity = 1

            didLabelAnimatinons = true
        }
    }
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            let percent: CGFloat = fabs(scrollView.contentOffset.y / (kHeaderViewHeight - navBarHeight))
            blurViewContainer.alpha = percent * 3
        } else {
            blurViewContainer.alpha = 0
        }
        if viewDidAppear {
            updateHeaderImageView()
        }
    }
}


