//
//  NewsListViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//
import UIKit
import SwiftyJSON
import AFNetworking
import KVNProgress

protocol NewsListViewControllerDelegate: class {
    func newsListViewControllerDidTapMenuButton(controller: NewsListViewController)
}

class NewsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingInfoView: UIView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loadLabel: UILabel!
    var currentPage = 1
    var totalPages = 0
    var populatingPosts = false
    var posts = [Post]()
    let refreshControl = UIRefreshControl()
    var baseURL: String!
    weak var delegate: NewsListViewControllerDelegate?
    var menuButton: MenuButton!
    var selectedIndexPath: NSIndexPath?
    let transition = ExpandingCellTransition()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = MenuButton()
        menuButton.tapHandler = {
            delegate?.newsListViewControllerDidTapMenuButton(self)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        tableView.separatorStyle = .None
        
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        loadingInfoView.alpha = 0
        loadingIndicator.startAnimating()
        
        navigationController?.delegate = self
        
        populatePosts()
    }
    
    func showLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 1
                self.loadingIndicator.alpha = 1
                self.loadLabel.text = "正在讀取文章"
            })
        }
    }
    
    func hideLoading() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 0
            })
        }
    }
    
    func showAllPostsLoaded() {
        dispatch_async(dispatch_get_main_queue()) {
            self.loadingInfoView.alpha = 1
            self.loadingIndicator.alpha = 0
            self.loadLabel.text = "所有文章讀取"
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.loadingInfoView.alpha = 0
            })
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + view.frame.size.height > scrollView.contentSize.height * 0.8 {
            populatePosts()
        }
    }
    
    func handleRefresh() {
        refreshControl.beginRefreshing()
        
        posts.removeAll(keepCapacity: false)
        self.currentPage = 1
        self.totalPages = 0
        
        tableView.reloadData()
        
        populatePosts()
    }
    
    func populatePosts() {
        if populatingPosts {
            return
        }
        
        if currentPage > totalPages && totalPages != 0{
            showAllPostsLoaded()
            populatingPosts = false
            return
        }
        
        showLoading()
        populatingPosts = true
        let getPostsURL = "\(baseURL)&count=8&page=\(currentPage)"
        let request = NSURLRequest(URL: NSURL(string: getPostsURL)!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            self.refreshControl.endRefreshing()
            println("request end")
            if error == nil {
                let json = JSON(data: data)
                self.totalPages = json["pages"].int!
                if self.currentPage <= self.totalPages {
                    let lastItem = self.posts.count
                    for index in 0..<json["posts"].arrayValue.count {
                        let newPost = Post(json: json["posts"][index])
                        self.posts.append(newPost)
                    }
                    let indexPaths = (lastItem..<self.posts.count).map{ NSIndexPath(forItem: $0, inSection: 0)}
                    dispatch_async(dispatch_get_main_queue()) {
                        self.tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
                    }
                    self.currentPage++
                }
            } else {
                println(error.userInfo?["error"] as? String)
            }
            self.hideLoading()
            self.populatingPosts = false
        }).resume()
    }
    
}

extension NewsListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 151
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = posts[indexPath.row]
        
        cell.titleLabel.text = post.title
        if let thumbnailURL = post.thumbnailUrl {
            let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
            cell.thumbnailImageView.addSubview(activityIndicator)
            activityIndicator.center = cell.thumbnailImageView.center
            activityIndicator.startAnimating()
            let request = NSURLRequest(URL: NSURL(string: thumbnailURL)!)
            cell.thumbnailImageView.setImageWithURLRequest(request, placeholderImage: nil, success: {
                (request: NSURLRequest!, response: NSHTTPURLResponse!, image: UIImage!) -> Void in
                activityIndicator.removeFromSuperview()
                cell.thumbnailImageView.image = image
                }, failure: nil)
        } else {
            println("no thumbnail \(currentPage-1) \(post.id)")
            cell.thumbnailImageView.image = UIColor.imageWithColor(kThemeColor)
        }
        return cell
    }
}

extension NewsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndexPath = indexPath
        let post = posts[indexPath.row]
        let postVC = UIStoryboard.postDetailViewController()
        postVC.post = post
        postVC.thumbnailImage = (tableView.cellForRowAtIndexPath(indexPath) as! PostCell).thumbnailImageView.image
        
        postVC.navigationController?.delegate = self
        self.navigationController?.pushViewController(postVC, animated: true)
        
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsZero
        cell.layoutMargins = UIEdgeInsetsZero
        cell.preservesSuperviewLayoutMargins = false
    }
}

extension NewsListViewController: ExpandingTransitionPresentingViewController {
    func expandingTransitionTargetViewForTransition(transition: ExpandingCellTransition) -> UIView! {
        if let indexPath = selectedIndexPath {
            return tableView.cellForRowAtIndexPath(indexPath)
        } else {
            return nil
        }
    }
}

extension NewsListViewController: UINavigationControllerDelegate {
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        if fromVC.isKindOfClass(AboutViewController) || toVC.isKindOfClass(AboutViewController) {
            return nil
        }
        
        if operation == UINavigationControllerOperation.Push {
            transition.type = .Presenting
            println("pushing")
        } else {
            transition.type = .Dismissing
            println("popping")
        }
        
        return transition
    }
}
