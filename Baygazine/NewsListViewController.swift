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

class NewsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var populatingPosts = false
    var posts = [Post]()
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "生活"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        tableView.separatorStyle = .None
        
        refreshControl.tintColor = UIColor.blackColor()
        refreshControl.addTarget(self, action: "handleRefresh", forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
        
        populatePosts()
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
        
        tableView.reloadData()
        
        populatePosts()
    }
    
    
    func populatePosts() {
        if populatingPosts {
            return
        }
        
        populatingPosts = true
        let getPostsURL = "http://baygazine.com/category/life-style/?json=1&count=8&page=\(currentPage)"
        let request = NSURLRequest(URL: NSURL(string: getPostsURL)!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            self.refreshControl.endRefreshing()
            if error == nil {
                let json = JSON(data: data)
                let totalPages = json["pages"].int
                if self.currentPage <= totalPages {
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
        
        cell.titleText = post.title
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
        let post = posts[indexPath.row]
        let postVC = UIStoryboard.postDetailViewController()
        postVC.post = post
        navigationController?.showViewController(postVC, sender: self)
    }
}