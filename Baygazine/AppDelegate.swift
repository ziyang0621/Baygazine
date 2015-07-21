//
//  AppDelegate.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/18/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

let kThemeColor = UIColor.colorWithRGBHex(0x0D72A8, alpha: 1.0)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var newsViewControllers = [UIViewController]()

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

        let lifeStyleNewsListVC = UIStoryboard.lifeStyleNewsListViewController()
        newsViewControllers.append(lifeStyleNewsListVC)
        mainNav = UINavigationController(rootViewController: newsViewControllers[0])
        
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

extension AppDelegate: MenuViewControllerDelegate {
    func menuViewController(controller: MenuViewController, didSelectRow row: Int) {
        println("menu vc delegate called")
    }
}
