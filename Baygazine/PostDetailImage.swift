//
//  PostDetailImage.swift
//  Baygazine
//
//  Created by Ziyang Tan on 8/15/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import hpple

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
    
    init(element: TFHppleElement) {
        super.init()
        
        let attributes =  element.attributes
        src = attributes["src"] as? String
        raw = element.raw
        var textRange = raw!.rangeOfString(" />", options: .LiteralSearch, range: nil, locale: nil)
        if textRange == nil {
            raw = raw!.stringByReplacingOccurrencesOfString("/>", withString: " />", options: .LiteralSearch, range: nil)
        }
        
       // let stringData = raw!.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
//        let attributedOptions : [String: AnyObject] = [
//            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
//            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding,
//        ]
        
        generateInfo()
    }
    
    private func generateInfo() {
        let fullMatch = String.matchesForRegexInTextFullMatch("\\?resize=\\d+\\%2C\\d+", text: src)
        
        if fullMatch.count > 0 {
            
            newSrc = src!.stringByReplacingOccurrencesOfString(fullMatch.first!, withString: "", options: .LiteralSearch, range: nil)
            
            let widthCaptureGroup = String.matchesForRegexInTextCaptureGroup("\\?resize=(.*)%2C", text: fullMatch.first)
            
            if widthCaptureGroup.count > 0 {
                if let widthNum = NSNumberFormatter().numberFromString(widthCaptureGroup.first!) {
                    width = CGFloat(widthNum)
                }
            }
            
             let heightCaptureGroup = String.matchesForRegexInTextCaptureGroup("%2C(.*)", text: fullMatch.first)
            
            if heightCaptureGroup.count > 0 {
                if let heightNum = NSNumberFormatter().numberFromString(heightCaptureGroup.first!) {
                    height = CGFloat(heightNum)
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
//            if theWidth > maxWidth {
                if let theHeight = height {
                    height = maxWidth / theWidth * theHeight
                }
                width = maxWidth
//            }
        }
    }
}
