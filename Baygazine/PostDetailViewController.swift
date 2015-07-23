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
    @IBOutlet weak var headerImageViewHeightLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerImageViewTopLayoutContraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabel: UILabel!
    var post: Post?
    var thumbnailImage: UIImage?
    var headerViewFrame: CGRect!
    var maximumStretchHeight: CGFloat?
    var didLayoutSubviews = false
    var headerImageViewFrame: CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        headerImageView.clipsToBounds = true
        headerImageViewFrame = headerImageView.frame
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
    
}

extension PostDetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if didLayoutSubviews {
            updateHeaderImageView()
        }
    }
}

