//
//  NewswireDetailViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class NewswireDetailViewController: UIViewController {

    //MARK: Properties
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var articleBodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageCaptionLabel: UILabel!
    @IBOutlet weak var webUrlLabel: UILabel!
   
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
     @IBOutlet weak var paddingAboveImageCaptionConstraint: NSLayoutConstraint!
    
    var newswireItem: NewswireItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let newswireItem = self.newswireItem {
            titleLabel.text = newswireItem.title
            webUrlLabel.text = newswireItem.webUrl
            
            if let abstract = newswireItem.abstract {
                articleBodyLabel.text = abstract
            }
            if let highResImgURL = newswireItem.highResImageURL where !highResImgURL.isEmpty,
                let imageCaption = newswireItem.imageCaption {
                imageView.downloadedFrom(link: highResImgURL, contentMode: .ScaleAspectFit)
                    imageCaptionLabel.text = imageCaption
            } else {
                imageViewHeightConstraint.constant = 0
                paddingAboveImageCaptionConstraint.constant = 0
                imageCaptionLabel.text = ""
                imageCaptionLabel.hidden = true
                imageCaptionLabel.frame.size.height = 0
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
