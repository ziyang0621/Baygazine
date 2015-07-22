//
//  PostDetailViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

private let kHeaderViewHeight: CGFloat = 200.0

class PostDetailViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var headerImageView: UIImageView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet private weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    var post: Post?
    var headerViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var headerImageViewHeight: CGFloat = 0
    var previousHeight: CGFloat = 0
    var didLayoutSubviews = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        headerViewFrame = headerView.frame
        headerImageView.clipsToBounds = true
        headerImageViewHeight = CGRectGetHeight(headerImageView.frame)
        maximumStretchHeight = CGRectGetWidth(scrollView.bounds)
        
        loadThumnailImage()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func loadThumnailImage() {
        if let thumbnailURL = post!.thumbnailUrl {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            headerImageView.addSubview(activityIndicator)
            activityIndicator.center = headerImageView.center
            activityIndicator.startAnimating()
            let request = NSURLRequest(URL: NSURL(string: thumbnailURL)!)
            headerImageView.setImageWithURLRequest(request, placeholderImage: nil, success: {
                (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                activityIndicator.removeFromSuperview()
                self.headerImageView.image = image
                }, failure: nil)
        } else {
            headerImageView.image = UIColor.imageWithColor(kThemeColor)
        }

    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        println("did layout")
        didLayoutSubviews = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateHeaderView() {
        let insets = scrollView.contentInset
        let offset = scrollView.contentOffset
        let minY = -insets.top
        println("offsetY \(offset.y) minY \(minY)")
        if offset.y < minY {
            let deltaY = fabs(offset.y - minY)
            var frame = headerViewFrame
            frame.size.height = min(max(minY, kHeaderViewHeight + deltaY), maximumStretchHeight!)
            frame.origin.y = CGRectGetMinY(frame) - deltaY
            headerView.frame = frame
            
            if (previousHeight != CGRectGetHeight(frame)) {
                println("previousHeight \(previousHeight)")
                headerImageViewHeightLayoutConstraint.constant = headerImageViewHeight + deltaY
                previousHeight = CGRectGetHeight(frame)
            }
        }

    }

    
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if didLayoutSubviews {
            updateHeaderView()
        }
    }
}

