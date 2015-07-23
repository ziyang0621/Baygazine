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
    @IBOutlet weak var titleLabel: UILabel!
    
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
