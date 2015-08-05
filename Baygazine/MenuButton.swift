//
//  MenuButton.swift
//  Baygazine
//
//  Created by Ziyang Tan on 8/5/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class MenuButton: UIView {
    
    var imageView: UIImageView!
    var tapHandler: (()->())?
    
    override func didMoveToSuperview() {
        if imageView == nil {
            frame = CGRect(x: 0.0, y: 0.0, width: 20.0, height: 20.0)
            
            imageView = UIImageView(image:UIImage(named:"MenuIcon")?.newImageWithColor(UIColor.whiteColor()))
            imageView.userInteractionEnabled = true
            imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTap")))
            addSubview(imageView)
        }
    }
    
    func didTap() {
        tapHandler?()
    }
}