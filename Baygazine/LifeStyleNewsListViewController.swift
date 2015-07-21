//
//  LifeStyleNewsListViewController.swift
//  
//
//  Created by Ziyang Tan on 7/20/15.
//
//

import UIKit

class LifeStyleNewsListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var currentPage = 1
    var populatingPosts = false

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
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
                let dict = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as! NSDictionary
                println(dict)
            } else {
                println(error.userInfo?["error"] as? String)
            }
        }).resume()
    }
    
}

extension LifeStyleNewsListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel!.text = "test"
        return cell
    }
}

extension LifeStyleNewsListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
}