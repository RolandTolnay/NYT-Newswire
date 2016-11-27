//
//  Article.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 12/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class Article {
    
    var headline: String
    var pubDate: NSDate
    
    var multimedia: [NSDictionary]?
    var leadParagraph: String?
    var abstract: String?
    var webURL: String?
    
    init(headline: String, pubDate: NSDate) {
        self.headline = headline
        self.pubDate = pubDate
    }
    
}
