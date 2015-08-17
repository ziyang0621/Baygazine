//
//  PostDetailImage.swift
//  Baygazine
//
//  Created by Ziyang Tan on 8/15/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class PostDetailImage: NSObject {
    var width: CGFloat? {
        didSet {
            updateNewRaw()
        }
    }
    var height: CGFloat? {
        didSet {
            updateNewRaw()
        }
    }
    var src: String?
    var newSrc: String?
    var raw: String?
    var newRaw: String?
    
    init(fullRaw: String) {
        super.init()
        
        raw = fullRaw
        
        generateInfo()
    }
    
    private func generateInfo() {
        let srcMatch = String.matchesForRegexInTextCaptureGroup("src=\"(.+?)\"", text: raw)
        if srcMatch.count > 0 {
            src = srcMatch.first
            
            let resizeMatch = String.matchesForRegexInTextFullMatch("\\?resize=\\d+\\%2C\\d+", text: src)
            
            if resizeMatch.count > 0 {
                
                newSrc = src!.stringByReplacingOccurrencesOfString(resizeMatch.first!, withString: "", options: .LiteralSearch, range: nil)
                
                let widthCaptureGroup = String.matchesForRegexInTextCaptureGroup("\\?resize=(.*)%2C", text: resizeMatch.first)
                
                if widthCaptureGroup.count > 0 {
                    if let widthNum = NSNumberFormatter().numberFromString(widthCaptureGroup.first!) {
                        width = CGFloat(widthNum)
                    }
                }
                
                let heightCaptureGroup = String.matchesForRegexInTextCaptureGroup("%2C(.*)", text: resizeMatch.first)
                
                if heightCaptureGroup.count > 0 {
                    if let heightNum = NSNumberFormatter().numberFromString(heightCaptureGroup.first!) {
                        height = CGFloat(heightNum)
                    }
                }
            }

        }
    }
    
    private func updateNewRaw() {
        if let raw = raw {
            if width != nil && height != nil && src != nil && newSrc != nil {
                let targetString = " width=\"\(width!)\" height=\"\(height!)\" />"
                newRaw = raw.stringByReplacingOccurrencesOfString("/>", withString: targetString, options: .LiteralSearch, range: nil)
                newRaw = newRaw!.stringByReplacingOccurrencesOfString(src!, withString: newSrc!, options: .LiteralSearch, range: nil)
            }
        }
    }
    
    func updateWidthAndHeightWithDeviceBounds(theBounds: CGRect) {
        let maxWidth = theBounds.size.width * 0.9
        if let theWidth = width {
            if let theHeight = height {
                height = maxWidth / theWidth * theHeight
            }
            width = maxWidth
        }
    }
}
