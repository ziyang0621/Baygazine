//
//  AboutViewController.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/24/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

protocol AboutViewControllerDelegate: class {
    func aboutViewControllerDidTapMenuButton(controller: AboutViewController)
}

class AboutViewController: UIViewController {

    @IBOutlet weak var aboutTextView: UITextView!
    weak var delegate: AboutViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let leftMenuButton = UIBarButtonItem(image: UIImage(named: "MenuIcon"), style: .Plain, target: self, action: "menuTapped")
        navigationItem.leftBarButtonItem = leftMenuButton
        
        aboutTextView.text = "about us page"
    }
    
    func menuTapped() {
        delegate?.aboutViewControllerDidTapMenuButton(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
