//
//  Author.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import SwiftyJSON

class Author: NSObject {
    var id: Int?
    var slug: String?
    var name: String?
    var firstName: String?
    var lastName: String?
    var nickName: String?
    var url: String?
    var descriptionText: String?
    
    init(json: JSON) {
        id = json["id"].int
        slug = json["slug"].string
        name = json["name"].string
        firstName = json["first_name"].string
        lastName = json["last_name"].string
        nickName = json["nickname"].string
        url = json["url"].string
        descriptionText = json["description"].string
    }
}
