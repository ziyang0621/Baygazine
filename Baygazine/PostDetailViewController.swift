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
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    var post: Post?
    var thumbnailImage: UIImage?
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
        titleLabel.text = post?.title!
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
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
        if offset.y < minY {
            let deltaY = fabs(offset.y - minY)
            var frame = headerViewFrame
            frame.size.height = min(max(minY, kHeaderViewHeight + deltaY), maximumStretchHeight!)
            frame.origin.y = CGRectGetMinY(frame) - deltaY
            headerView.frame = frame
            
            if (previousHeight != CGRectGetHeight(frame)) {
                headerImageViewHeightLayoutConstraint.constant = headerImageViewHeight + deltaY
                previousHeight = CGRectGetHeight(frame)
            }
            
            println("\(gradientView.frame) \(headerImageView.frame) \(headerView.frame)")
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

