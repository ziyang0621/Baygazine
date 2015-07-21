//
//  LifeStyleNewsListViewController.swift
//  
//
//  Created by Ziyang Tan on 7/20/15.
//
//

import UIKit
import SwiftyJSON
import AFNetworking

class LifeStyleNewsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var populatingPosts = false
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        populatePosts()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func populatePosts() {
        if populatingPosts {
            return
        }
        
        populatingPosts = true
        let getPostsURL = "http://baygazine.com/category/life-style/?json=1&page=\(currentPage)"
        let request = NSURLRequest(URL: NSURL(string: getPostsURL)!)
        let session = NSURLSession.sharedSession()
        session.dataTaskWithRequest(request, completionHandler: {
            (data: NSData!, response: NSURLResponse!, error: NSError!) -> Void in
            if error == nil {
                let json = JSON(data: data)
                for index in 0..<json["posts"].arrayValue.count {
                    let newPost = Post(json: json["posts"][index])
                    self.posts.append(newPost)
                }
                dispatch_async(dispatch_get_main_queue()) {
                    self.tableView.reloadData()
                }
            } else {
                println(error.userInfo?["error"] as? String)
            }
        }).resume()
    }
    
}

extension LifeStyleNewsListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PostCell", forIndexPath: indexPath) as! PostCell
        let post = posts[indexPath.row]
        cell.titleLabel.text = post.title
        cell.thumbnailImageView.setImageWithURL(NSURL(string: post.thumbnailUrl!)!)
        return cell
    }
}

extension LifeStyleNewsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}