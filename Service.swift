//
//  Service.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 12/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

//MARK: Extensions

//Allows async download of image from URL
extension UIImageView {
    func downloadedFrom(link link: String, contentMode mode: UIViewContentMode) {
        guard
            let url = NSURL(string: link)
            else {return}
        contentMode = mode
        
        self.layoutIfNeeded()
        var activityIndicator = UIActivityIndicatorView()
        let horizontalCenter = self.bounds.size.width / 2
        let verticalCenter = self.bounds.size.height / 2
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(horizontalCenter - 10, verticalCenter - 10, 20, 20))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.hidesWhenStopped = true
        self.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        NSURLSession.sharedSession().dataTaskWithURL(url, completionHandler: { (data, _, error) -> Void in
            guard
                let data = data where error == nil,
                let image = UIImage(data: data)
                else { return }
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.image = image
                activityIndicator.stopAnimating()
                activityIndicator.removeFromSuperview()
            }
        }).resume()
    }
}

extension Array where Element : Equatable {
    mutating func removeObject(object : Element) {
        if let index = self.indexOf(object) {
            self.removeAtIndex(index)
        }
    }
}

//MARK: JSON parsing and data storage

class Service {
    
    static let sharedInstance = Service()
    
    //MARK: API Keys
    
    //API Key identifiers
    struct APIKeyIdentifier {
        static let articleSearchKey = "ArticleSearchKey"
        static let newsWireKey = "TimesNewsWireKey"
        static let topStoriesKey = "TopStoriesKey"
    }
    
    var articleSearchAPIKey: String
    var newsWireAPIKey: String
    var topStoriesAPIKey: String
    
    //Array that stores saved top stories
    var savedTopStories: [TopStory]?
    
    let dateFormatter = NSDateFormatter()
    
    private init() {
        
        // load API KEYS from NSUserDefaults
        
        let prefs = NSUserDefaults.standardUserDefaults()
        if let articleSearchKey = prefs.stringForKey(APIKeyIdentifier.articleSearchKey),
            newsWireKey = prefs.stringForKey(APIKeyIdentifier.newsWireKey),
            topStoriesKey = prefs.stringForKey(APIKeyIdentifier.topStoriesKey)  {
                articleSearchAPIKey = articleSearchKey
                newsWireAPIKey = newsWireKey
                topStoriesAPIKey = topStoriesKey
                print("Retrieved API Key from phone")
        } else {
            articleSearchAPIKey = "10705f2670fe7c9973c04a9b09896e26:9:73724489"
            newsWireAPIKey = "43416744e70d8eb2954d349362e2f078:11:73724489"
            topStoriesAPIKey = "eec98fb8e0738f8c817b30e894650cfb:6:73724489"
            prefs.setObject(articleSearchAPIKey, forKey: APIKeyIdentifier.articleSearchKey)
            prefs.setObject(newsWireAPIKey, forKey: APIKeyIdentifier.newsWireKey)
            prefs.setObject(topStoriesAPIKey, forKey: APIKeyIdentifier.topStoriesKey)
            print("Created and stored API Keys in phone")
        }
        
        if let savedTopStories = loadTopStoriesFromArchive() where savedTopStories.count > 0 {
            self.savedTopStories = savedTopStories
        } else {
            savedTopStories = [TopStory]()
        }
    }
    
    //MARK: Article Search
    
    func getArticlesContainingString(searchString: String, pageNumber: String, completionHandler: (articles: [Article]) -> ()) {
        
        var matchingArticles = [Article]()
        
        let userDataSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var requestString = "http://api.nytimes.com/svc/search/v2/articlesearch.json"
        let formattedSearchString = searchString.stringByReplacingOccurrencesOfString(" ", withString: "+")
        requestString += "?q=" + formattedSearchString
        requestString += "&page=" + pageNumber
        requestString += "&api-key=" + articleSearchAPIKey
        let requestURL = NSURL(string: requestString)
        
        let userDataSession = NSURLSession(
            configuration: userDataSessionConfiguration,
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let getArticlesTask = userDataSession.dataTaskWithURL(requestURL!) {
            (data, response, error) -> Void in
            
            if error == nil {
                
                let articlesJSON = JSON(data: data!)
                
                let articleArray = articlesJSON["response"]["docs"]
                for (_,articleJSON):(String, JSON) in articleArray {
                    if let article = self.createArticleFromJSON(articleJSON) {
                        matchingArticles.append(article)
                    }
                }
                
                completionHandler(articles: matchingArticles)
            }
        }
        getArticlesTask.resume()
        
    }
    
    func createArticleFromJSON(articleJSON: JSON) -> Article? {
        
        var article: Article?
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let headline = articleJSON["headline"]["main"].string,
            pubDateString = articleJSON["pub_date"].string,
            pubDate = dateFormatter.dateFromString(pubDateString) {
                
                let formattedHeadline = headline.stringByDecodingHTMLEntities
                article = Article(headline: formattedHeadline, pubDate: pubDate)
                
                if let webUrl = articleJSON["web_url"].string {
                    article!.webURL = webUrl
                }
                if let leadParagraph = articleJSON["lead_paragraph"].string where !leadParagraph.isEmpty {
                    article!.leadParagraph = leadParagraph.stringByDecodingHTMLEntities
                }
                if let abstract = articleJSON["abstract"].string where !abstract.isEmpty {
                    article!.abstract = abstract.stringByDecodingHTMLEntities
                }
                if let multimedia = articleJSON["multimedia"].array {
                    article!.multimedia = [NSDictionary]()
                    for imageJSON in multimedia {
                        article!.multimedia!.append(
                            [   "url": imageJSON["url"].stringValue,
                                "width": imageJSON["width"].intValue,
                                "height": imageJSON["height"].intValue
                            ])
                    }
                }
        }
        
        return article
    }
    
    //MARK: Newswire
    
    func getNewswireItems(section: String,  completionHandler: (newswireItems: [NewswireItem]) -> ()) {
        
        var newswireItems = [NewswireItem]()
        
        let userDataSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var requestString = "http://api.nytimes.com/svc/news/v3/content/nyt"
        requestString += "/" + section
        requestString += "?api-key=" + newsWireAPIKey
        let requestURL = NSURL(string: requestString)
        
        let userDataSession = NSURLSession(
            configuration: userDataSessionConfiguration,
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let getNewswireItemsTask = userDataSession.dataTaskWithURL(requestURL!) {
            (data, response, error) -> Void in
            
            if error == nil {
                
                let newswireItemsJSON = JSON(data: data!)
                
                let newswireItemsArray = newswireItemsJSON["results"]
                for (_,newswireItemJSON):(String, JSON) in newswireItemsArray {
                    if let newswireItem = self.createNewswireItemFromJSON(newswireItemJSON) {
                        newswireItems.append(newswireItem)
                    }
                }
                
                completionHandler(newswireItems: newswireItems)
            }
        }
        getNewswireItemsTask.resume()
    }
    
    //Returns an array of newswiresections containing their respective newswireItems
    func getNewswireSections(completionHandler: (newswireSections: [NewswireSection]) -> ()) {
        
        var newswireSections = [NewswireSection]()
        
        var allNewswireItems = [NewswireItem]()
        
        getNewswireItems("all") {
            newswireItems in
            allNewswireItems = newswireItems
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)) {
                allNewswireItems.sortInPlace({ $0.section < $1.section })
                var currentSectionName = allNewswireItems[0].section
                var currentSectionItems = [NewswireItem]()
                for i in 0..<allNewswireItems.count {
                    if allNewswireItems[i].section != currentSectionName {
                        let filledSection = NewswireSection(sectionName: currentSectionName, items: currentSectionItems)
                        newswireSections.append(filledSection)
                        currentSectionName = allNewswireItems[i].section
                        currentSectionItems = [NewswireItem]()
                        currentSectionItems.append(allNewswireItems[i])
                    } else {
                        currentSectionItems.append(allNewswireItems[i])
                    }
                }
                let filledSection = NewswireSection(sectionName: currentSectionName, items: currentSectionItems)
                newswireSections.append(filledSection)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(newswireSections: newswireSections)
                }
                
            }
        }
    }
    
    func createNewswireItemFromJSON(newswireJSON: JSON) -> NewswireItem? {
        
        var newswireItem: NewswireItem?
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let section = newswireJSON["section"].string,
            title = newswireJSON["title"].string,
            pubDateString = newswireJSON["published_date"].string,
            pubDate = dateFormatter.dateFromString(pubDateString),
            webUrl = newswireJSON["url"].string {
                
                let formattedTitle = title.stringByDecodingHTMLEntities
                newswireItem = NewswireItem(section: section, title: formattedTitle, pubDate: pubDate, webUrl: webUrl)
                
                if let thumbnailURL = newswireJSON["thumbnail_standard"].string {
                    newswireItem!.thumbnailURL = thumbnailURL
                }
                if let abstract = newswireJSON["abstract"].string where !abstract.isEmpty {
                    newswireItem!.abstract = abstract.stringByDecodingHTMLEntities
                }
                if let multimedia = newswireJSON["multimedia"].array,
                    highResImageURL = multimedia[multimedia.count - 1]["url"].string,
                    imageCaption = multimedia[0]["caption"].string {
                        newswireItem!.highResImageURL = highResImageURL
                        newswireItem!.imageCaption = imageCaption
                }
        }
        
        return newswireItem
    }
    
    //MARK: Top stories
    
    func getTopStorySection(section: String, completionHandler: (topStorySections: [TopStorySection]) -> ()) {
        
        var topStorySections = [TopStorySection]()
        
        let userDataSessionConfiguration = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        var requestString = "http://api.nytimes.com/svc/topstories/v1"
        requestString += "/" + section
        requestString += ".json"
        requestString += "?api-key=" + topStoriesAPIKey
        let requestURL = NSURL(string: requestString)
        
        let userDataSession = NSURLSession(
            configuration: userDataSessionConfiguration,
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue())
        
        let getTopStoriesTask = userDataSession.dataTaskWithURL(requestURL!) {
            (data, response, error) -> Void in
            
            if error == nil {
                
                let topStoriesJSON = JSON(data: data!)
                var allTopStories = [TopStory]()
                
                let topStoriesArray = topStoriesJSON["results"]
                for (_,topStoryJSON):(String, JSON) in topStoriesArray {
                    if let topStory = self.createTopStoryFromJSON(topStoryJSON) {
                        allTopStories.append(topStory)
                    }
                }
                
                if allTopStories.count > 0 {
                    allTopStories.sortInPlace({ $0.section < $1.section })
                    var currentSectionName = allTopStories[0].section
                    var currentSectionItems = [TopStory]()
                    for i in 0..<allTopStories.count {
                        if allTopStories[i].section != currentSectionName {
                            let filledSection = TopStorySection(sectionName: currentSectionName, items: currentSectionItems)
                            topStorySections.append(filledSection)
                            currentSectionName = allTopStories[i].section
                            currentSectionItems = [TopStory]()
                            currentSectionItems.append(allTopStories[i])
                        } else {
                            currentSectionItems.append(allTopStories[i])
                        }
                    }
                    let filledSection = TopStorySection(sectionName: currentSectionName, items: currentSectionItems)
                    topStorySections.append(filledSection)
                    
                }
                
                completionHandler(topStorySections: topStorySections)
            }
        }
        getTopStoriesTask.resume()
    }
    
    func createTopStoryFromJSON(topStoryJSON: JSON) -> TopStory? {
        
        var topStory: TopStory?
        
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        if let section = topStoryJSON["section"].string,
            title = topStoryJSON["title"].string,
            pubDateString = topStoryJSON["published_date"].string,
            pubDate = checkStringForValidDate(pubDateString),
            let webUrl = topStoryJSON["url"].string {
                
                let formattedTitle = title.stringByDecodingHTMLEntities
                topStory = TopStory(section: section, title: formattedTitle, pubDate: pubDate, webUrl: webUrl)
                
                if let abstract = topStoryJSON["abstract"].string where !abstract.isEmpty {
                    topStory!.abstract = abstract.stringByDecodingHTMLEntities
                }
                if let multimedia = topStoryJSON["multimedia"].array {
                    if let highResImageURL = multimedia[multimedia.count - 1]["url"].string {
                        topStory!.highResImageURL = highResImageURL
                    }
                    if let thumbnailURL = multimedia[0]["url"].string {
                        topStory!.thumbnailURL = thumbnailURL
                    }
                    if let imageCaption = multimedia[0]["caption"].string {
                        topStory!.imageCaption = imageCaption
                    }
                }
        }
        return topStory
    }
    
    /*
    Helper method
    Top-stories API returns published date string as
    "2015-12-14T00:00:00-5:00" instead of "2015-12-14T00:00:00-05:00"
    */
    func checkStringForValidDate(dateString: String) -> NSDate? {
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        var pubDate: NSDate?
        if let pubDateOptional = dateFormatter.dateFromString(dateString) {
            pubDate = pubDateOptional
        } else {
            var dateComponents = dateString.componentsSeparatedByString(":")
            let timezone = dateComponents[dateComponents.count-2]
            dateComponents[dateComponents.count-2] = timezone.stringByReplacingOccurrencesOfString("-", withString: "-0")
            let formattedPubDateString = dateComponents.joinWithSeparator(":")
            if let pubDateOptional = dateFormatter.dateFromString(formattedPubDateString) {
                pubDate = pubDateOptional
            }
        }
        
        return pubDate
    }
    
    //MARK: Favorites
    
    func getFavoriteTopStorySections(completionHandler: (topStorySections: [TopStorySection]?) -> ()) {
        
        var topStorySections: [TopStorySection]?
        if let topStories = savedTopStories where savedTopStories!.count > 0 {
            
            topStorySections = [TopStorySection]()
            
            dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INTERACTIVE.rawValue), 0)) {
                
                let sortedTopStories = topStories.sort({ $0.section < $1.section })
                
                var currentSectionName = sortedTopStories[0].section
                var currentSectionItems = [TopStory]()
                for i in 0..<sortedTopStories.count {
                    if sortedTopStories[i].section != currentSectionName {
                        let filledSection = TopStorySection(sectionName: currentSectionName, items: currentSectionItems)
                        topStorySections!.append(filledSection)
                        currentSectionName = sortedTopStories[i].section
                        currentSectionItems = [TopStory]()
                        currentSectionItems.append(sortedTopStories[i])
                    } else {
                        currentSectionItems.append(sortedTopStories[i])
                    }
                }
                let filledSection = TopStorySection(sectionName: currentSectionName, items: currentSectionItems)
                topStorySections!.append(filledSection)
                dispatch_async(dispatch_get_main_queue()) {
                    completionHandler(topStorySections: topStorySections)
                }
            }
        } else {
            completionHandler(topStorySections: nil)
        }
    }
    
    func isTopStorySaved(topStory: TopStory) -> Bool {
        return savedTopStories?.indexOf(topStory) != nil
    }
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("topStories")
    
    //NSCoding
    
    func loadTopStoriesFromArchive() -> [TopStory]? {
        let topStories = NSKeyedUnarchiver.unarchiveObjectWithFile(Service.ArchiveURL.path!) as? [TopStory]
        return topStories
    }
    
    
    //MARK: Manage storage of top stories
    func saveTopStory(topStory: TopStory){
        if let _ = self.savedTopStories {
            self.savedTopStories!.append(topStory)
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.savedTopStories!, toFile: Service.ArchiveURL.path!)
            if !isSuccessfulSave {
                print("Failed to save top stories")
            }
        }
    }
    
    func removeTopStory(topStory: TopStory) {
        if let _ = self.savedTopStories {
            self.savedTopStories!.removeObject(topStory)
            let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(self.savedTopStories!, toFile: Service.ArchiveURL.path!)
            if !isSuccessfulSave {
                print("Failed to save top stories")
            }
            
        }
    }
    
}




