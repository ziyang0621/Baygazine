//
//  MenuVIewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

protocol MenuViewControllerDelegate: class {
    func menuViewController(controller: MenuViewController, didSelectRow row: Int)
}

class MenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    weak var delegate: MenuViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = "Baygazine!"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: "MenuCell", bundle: nil), forCellReuseIdentifier: "MenuCell")
        tableView.rowHeight = 100
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension MenuViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MenuCell") as! MenuCell
        cell.backgroundColor = UIColor.clearColor()
        if indexPath.row < 5 {
            cell.menuText = kCategories[indexPath.row]
        } else {
            cell.menuText = "關於Baygazine"
        }
        return cell
    }
}

extension MenuViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.menuViewController(self, didSelectRow: indexPath.row)
    }
}
