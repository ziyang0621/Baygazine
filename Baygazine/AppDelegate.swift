//
//  AppDelegate.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/18/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

let kThemeColor = UIColor.colorWithRGBHex(0x0D72A8, alpha: 1.0)
let kCategoryURLs = ["http://baygazine.com/?json=get_recent_posts",
    "http://baygazine.com/category/life-style/?json=1",
    "http://baygazine.com/category/eat-and-drink/?json=1",
    "http://baygazine.com/category/news-and-politics/?json=1",
    "http://baygazine.com/category/column/?json=1",
    "http://baygazine.com/category/contribution/?json=1"]
let kCategories = ["最新","生活", "飲食", "新聞及政治", "專欄", "讀者投稿"]
let kCategoryImageNames = ["Recent", "LifeStyle", "Drink", "Political", "Column", "Reader", "About"]

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var mainViewControllers = [UIViewController]()

    var mainNav: UINavigationController!
    var menuNav: UINavigationController!
    var sidebarVC: SidebarViewController!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        let titleDict: NSDictionary = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        UINavigationBar.appearance().titleTextAttributes = titleDict as [NSObject : AnyObject]
        
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
        
        UINavigationBar.appearance().setBackgroundImage(UIColor.imageWithColor(kThemeColor), forBarMetrics: .Default)
        UINavigationBar.appearance().shadowImage = UIColor.imageWithColor(kThemeColor)
        UINavigationBar.appearance().translucent = true

        let newsListVC = UIStoryboard.newsListViewController()
        newsListVC.navigationItem.title = kCategories[0]
        newsListVC.baseURL = kCategoryURLs[0]
        newsListVC.delegate = self
        mainViewControllers.append(newsListVC)
        mainNav = UINavigationController(rootViewController: mainViewControllers[0])
        
        let aboutVC = UIStoryboard.aboutViewController()
        aboutVC.delegate = self
        mainViewControllers.append(aboutVC)
        
        let menuVC = UIStoryboard.menuViewController()
        menuVC.delegate = self
        menuNav = UINavigationController(rootViewController: menuVC)
        
        sidebarVC = SidebarViewController(leftViewController: menuNav, mainViewController: mainNav, overlap: 50)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = sidebarVC
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}

extension AppDelegate: AboutViewControllerDelegate {
    func aboutViewControllerDidTapMenuButton(controller: AboutViewController) {
        sidebarVC.toggleLeftMenuAnimated(true)
    }
}

extension AppDelegate: NewsListViewControllerDelegate {
    func newsListViewControllerDidTapMenuButton(controller: NewsListViewController) {
        sidebarVC.toggleLeftMenuAnimated(true)
    }
}

extension AppDelegate: MenuViewControllerDelegate {
    func menuViewController(controller: MenuViewController, didSelectRow row: Int) {
        sidebarVC.closeMenuAnimated(true)
        var viewControllerIndex = 0

        if (row < 6) {
            viewControllerIndex = 0
            (mainViewControllers[0] as! NewsListViewController).baseURL = kCategoryURLs[row]
            (mainViewControllers[0] as! NewsListViewController).navigationItem.title = kCategories[row]
            (mainViewControllers[0] as! NewsListViewController).handleRefresh()
        } else {
            viewControllerIndex = 1
            (mainViewControllers[1] as! AboutViewController).navigationItem.title = "關於Baygazine!"
        }
        
        let destinationViewController = mainViewControllers[viewControllerIndex]
        if mainNav.topViewController != destinationViewController {
            mainNav.setViewControllers([destinationViewController], animated: true)
        }
    }
}
