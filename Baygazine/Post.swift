//
//  Post.swift
//  Baygazine
//
//  Created by Ziyang Tan on 7/21/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit
import SwiftyJSON

class Post: NSObject {
    var id: Int?
    var url: String?
    var title: String?
    var attachments: [Attachment]?
    var thumbnailUrl: String?
    var author: Author?
    var createdDate: String?
    var modifiedDate: String?
    var content: String?
    var excerpt: String?
    
    init(json: JSON) {
        id = json["id"].int
        url = json["url"].string
        title = String(htmlEncodedString: json["title"].string!)
        attachments = [Attachment]()
        for index in 0..<json["attachments"].array!.count {
            let attachment = Attachment(json: json["attachments"][index])
            attachments?.append(attachment)
        }
        thumbnailUrl = json["attachments"][0]["url"].string
        author = Author(json: json["author"])
        createdDate = json["date"].string
        modifiedDate = json["modified"].string
        content = json["content"].string
        excerpt = json["excerpt"].string
    }
}