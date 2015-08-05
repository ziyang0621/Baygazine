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
    var menuButton: MenuButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuButton = MenuButton()
        menuButton.tapHandler = {
            delegate?.aboutViewControllerDidTapMenuButton(self)
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuButton)
        
        aboutTextView.text = "Baygazine.com is a website established by several college students living in the Bay Area in 2015. The website aims to create an online new-media platform for the Chinese American community in the San Francisco Bay Area. The contents includes but not limited to lifestyle, news, politics and all other Bay Area information that close to the community. Reader is not only reading the articles, but also contribute to the site with brainstorming ideas.\n\n Baygazine.com係一個由數名生活於灣區的大學生創辦的網站。目的係為三藩市灣區華人社區創立一個網上新文字媒體平台。內容涵括生活、新聞政治、及各種灣區資訊，貼近灣區華人生活脈搏。讀者除了可以閱讀本站文章外，更可向本站投稿，集思廣益。"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
