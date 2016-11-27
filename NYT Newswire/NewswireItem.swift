//
//  NewswireItem.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 13/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class NewswireItem: NSObject, NSCoding {
    
    var section: String
    var title: String
    var pubDate: NSDate
    var webUrl: String
    
    var abstract: String? 
    var thumbnailURL: String?
    var highResImageURL: String?
    var imageCaption: String?
    
    init(section: String, title: String, pubDate: NSDate, webUrl: String){
        self.section = section
        self.title = title
        self.pubDate = pubDate
        self.webUrl = webUrl
    }
    
    //MARK: Types
    
    struct PropertyKey {
        static let sectionKey = "section"
        static let titleKey = "title"
        static let pubDateKey = "pubDate"
        static let abstractKey = "abstract"
        static let webUrlKey = "webUrl"
        static let thumbnailURLKey = "thumbnalURL"
        static let highResImageURLKey = "highResImageURL"
        static let imageCaptionKey = "imageCaption"
    }
    
    //MARK: NSCoding
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(section, forKey: PropertyKey.sectionKey)
        aCoder.encodeObject(title, forKey: PropertyKey.titleKey)
        aCoder.encodeObject(pubDate, forKey: PropertyKey.pubDateKey)
        aCoder.encodeObject(webUrl, forKey: PropertyKey.webUrlKey)
        
        if let abstract = self.abstract {
            aCoder.encodeObject(abstract, forKey: PropertyKey.abstractKey)
        }
        if let thumbnailURL = self.thumbnailURL {
            aCoder.encodeObject(thumbnailURL, forKey: PropertyKey.thumbnailURLKey)
        }
        if let highResImageURL = self.highResImageURL {
            aCoder.encodeObject(highResImageURL, forKey: PropertyKey.highResImageURLKey)
        }
        if let imageCaption = self.imageCaption {
            aCoder.encodeObject(imageCaption, forKey: PropertyKey.imageCaptionKey)
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let section = aDecoder.decodeObjectForKey(PropertyKey.sectionKey) as! String
        let title = aDecoder.decodeObjectForKey(PropertyKey.titleKey) as! String
        let pubDate = aDecoder.decodeObjectForKey(PropertyKey.pubDateKey) as! NSDate
        let webUrl = aDecoder.decodeObjectForKey(PropertyKey.webUrlKey) as! String
        
        self.init(section: section, title: title, pubDate: pubDate, webUrl: webUrl)
        
        if let abstract = aDecoder.decodeObjectForKey(PropertyKey.abstractKey) as? String {
            self.abstract = abstract
        }
        if let thumbnailURL = aDecoder.decodeObjectForKey(PropertyKey.thumbnailURLKey) as? String {
            self.thumbnailURL = thumbnailURL
        }
        if let highResImageURL = aDecoder.decodeObjectForKey(PropertyKey.highResImageURLKey) as? String {
            self.highResImageURL = highResImageURL
        }
        if let imageCaption = aDecoder.decodeObjectForKey(PropertyKey.imageCaptionKey) as? String {
            self.imageCaption = imageCaption
        }
    }
    
    //MARK: Equatable
    
    override func isEqual(object: AnyObject?) -> Bool {
        if let rhs = object as? NewswireItem {
            return webUrl == rhs.webUrl
        }
        return false
    }
}

class NewswireSection {
    
    var sectionName: String
    var items: [NewswireItem]
    
    init(sectionName: String, items: [NewswireItem]){
        self.sectionName = sectionName
        self.items = items
    }
    
}