//
//  TopStoryTableViewCell.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

protocol SaveTopStoryDelegate {
    
    func saveTopStory(sender: TopStoryTableViewCell)
    func removeTopStory(sender: TopStoryTableViewCell)
}

class TopStoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var pubDateLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var delegate: SaveTopStoryDelegate?
    
    @IBAction func saveTopStory(sender: UIButton) {
        favoriteButton.selected = !favoriteButton.selected
        if let delegate = self.delegate {
            if favoriteButton.selected {
                //save top story
                delegate.saveTopStory(self)
            } else {
                //remove top story
                delegate.removeTopStory(self)
            }
        }
    }
    
    
}
