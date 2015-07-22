//
//  PostCell.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet private weak var gradientView: GradientView!
    @IBOutlet private weak var titleTextView: UITextView!
        
    var titleText: String? {
        didSet {
            if let titleText = titleText {
                titleTextView.text = titleText
                titleTextView.textColor = UIColor.whiteColor()
                titleTextView.font = UIFont(name: "HelveticaNeue", size: 17)
                titleTextView.textAlignment = .Center
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        thumbnailImageView.clipsToBounds = true
        selectionStyle = .None
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
