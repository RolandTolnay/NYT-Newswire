//
//  ArticleDetailViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 13/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit



class ArticleDetailViewController: UIViewController  {
    
    //MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleBodyLabel: UILabel!
    @IBOutlet weak var webUrlLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var relatedImagesLabel: UILabel!
    
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var paddingBelowImageViewConstraint: NSLayoutConstraint!
    
    var article: Article?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let article = article {
            titleLabel.text = article.headline
            var articleBody = ""
            if let leadParagraph = article.leadParagraph {
                articleBody += leadParagraph
            }
            if let abstract = article.abstract {
                articleBody += "\n\n"
                articleBody += abstract
            }
            if !articleBody.isEmpty {
                articleBodyLabel.text = articleBody
            } else {
                articleBodyLabel.text = "No content to display"
            }
            if let webUrl = article.webURL {
                webUrlLabel.text = webUrl
            }
            
            if let multimedia = article.multimedia where multimedia.count > 0 {
                let imageURL = multimedia[0]["url"] as! String
                let completeImageURL = "http://www.nytimes.com/" + imageURL
                imageView.downloadedFrom(link: completeImageURL, contentMode: .ScaleAspectFit)
            } else {
                imageViewHeightConstraint.constant = 0
                relatedImagesLabel.hidden = true
                relatedImagesLabel.frame.size.height = 0
                paddingBelowImageViewConstraint.constant = 0
            }
            
        }
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openLinkSegue" {
            let webBrowserViewController = segue.destinationViewController as! WebBrowserViewController
            webBrowserViewController.urlString = webUrlLabel.text!
        }
    }
    
    
    
}
