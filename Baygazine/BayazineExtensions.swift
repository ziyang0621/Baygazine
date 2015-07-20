//
//  BayazineExtensions.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func lifeStyleNewsListViewController() ->  LifeStyleNewsListViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("LifeStyleNewsListViewController") as! LifeStyleNewsListViewController
    }
    
    class func menuViewController() -> MenuViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
    }
}