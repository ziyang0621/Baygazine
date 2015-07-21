//
//  Attachment.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import SwiftyJSON

class Attachment: NSObject {
    var id:Int?
    var url:String?
    
    init(json: JSON) {
        id = json["id"].int
        url = json["url"].string
    }
}
