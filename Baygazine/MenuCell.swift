//
//  MenuCell.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {

    @IBOutlet weak var menuImageView: UIImageView!
    @IBOutlet weak var menuLabel: UILabel!

    var menuText: String? {
        didSet {
            if let menuText = menuText {
                menuLabel.text = menuText
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        menuLabel.textColor = kThemeColor
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
