//
//  BayazineExtensions.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

extension String {
    init(htmlEncodedString: String) {
        let encodedData = htmlEncodedString.dataUsingEncoding(NSUTF8StringEncoding)!
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
            NSFontAttributeName: UIFont(name: "HelveticaNeue", size: 17)!
        ]
        let attributedString = NSMutableAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
        self.init(attributedString.string)
    }
}

extension UIColor {
    class func imageWithColor(color :UIColor) -> UIImage {
        let rect = CGRectMake(0, 0, 1, 1)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    class func colorWithRGBHex(hex: Int, alpha: Float = 1.0) -> UIColor {
        let r = Float((hex >> 16) & 0xFF)
        let g = Float((hex >> 8) & 0xFF)
        let b = Float((hex) & 0xFF)
        
        return UIColor(
            red: CGFloat(r / 255.0),
            green: CGFloat(g / 255.0),
            blue:CGFloat(b / 255.0),
            alpha: CGFloat(alpha))
    }
}

extension UIImage {
    func newImageWithColor(color1: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        color1.setFill()
        
        let context = UIGraphicsGetCurrentContext() as CGContextRef
        CGContextTranslateCTM(context, 0, self.size.height)
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetBlendMode(context, kCGBlendModeNormal)
        
        let rect = CGRectMake(0, 0, self.size.width, self.size.height) as CGRect
        CGContextClipToMask(context, rect, self.CGImage)
        CGContextFillRect(context, rect)
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        
        return newImage
    }
}

extension NSDate {
    class func baygazineJSONDateToFormattedDate(bgDateString: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateFromString = dateFormatter.dateFromString(bgDateString)
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.stringFromDate(dateFromString!)
    }
}

extension UIStoryboard {
    class func mainStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
    }
    
    class func newsListViewController() -> NewsListViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("NewsListViewController") as! NewsListViewController
    }
    
    class func menuViewController() -> MenuViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("MenuViewController") as! MenuViewController
    }
    
    class func postDetailViewController() -> PostDetailViewController {
        return mainStoryboard().instantiateViewControllerWithIdentifier("PostDetailViewController") as! PostDetailViewController
    }
}