//
//  FavoritesViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class FavoritesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noContentLabel: UILabel!
    
    let service = Service.sharedInstance
    var topStorySections = [TopStorySection]()
    let dateFormatter = NSDateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 86
    }
    
    override func viewWillAppear(animated: Bool) {
        activityIndicator.startAnimating()
        tableView.hidden = true
        service.getFavoriteTopStorySections() {
            topStorySections in
            if let savedTopStorySections = topStorySections {
                self.topStorySections = savedTopStorySections
                self.tableView.hidden = false
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            } else {
                self.tableView.hidden = false
                self.activityIndicator.stopAnimating()
            }
            self.checkForContent()
        }
    }
    
    func checkForContent() {
        if topStorySections.count == 0 {
            tableView.hidden = true
            noContentLabel.hidden = false
        } else {
            tableView.hidden = false
            noContentLabel.hidden = true
        }
    }

    
    //MARK: Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return topStorySections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStorySections[section].items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "favoritesCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! FavoritesTableViewCell
        
        let topStory = topStorySections[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = topStory.title
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.pubDateLabel.text = "Published: " + dateFormatter.stringFromDate(topStory.pubDate)
        if let thumbnailURL = topStory.thumbnailURL where !thumbnailURL.isEmpty {
            cell.thumbnailImageView.downloadedFrom(link: thumbnailURL, contentMode: .ScaleAspectFit)
        } else {
            cell.thumbnailImageView.image = UIImage(named: "noThumbnail")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return topStorySections[section].sectionName
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let topStoryToBeRemoved = topStorySections[indexPath.section].items[indexPath.row]
            
            tableView.beginUpdates()
            let affectedSection = topStorySections[indexPath.section]
            affectedSection.items.removeObject(topStoryToBeRemoved)
            if affectedSection.items.count == 0 {
                topStorySections.removeObject(affectedSection)
                tableView.deleteSections(NSIndexSet(index: indexPath.section), withRowAnimation: .Fade)
            }
            service.removeTopStory(topStoryToBeRemoved)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            tableView.endUpdates()
            checkForContent()
        }
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showFavoritesDetailSegue" {
            let favoritesDetailViewController = segue.destinationViewController as! NewswireDetailViewController
            if let selectedFavoritesCell = sender as? FavoritesTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedFavoritesCell)!
                let selectedTopStory = topStorySections[indexPath.section].items[indexPath.row]
                favoritesDetailViewController.newswireItem = selectedTopStory
            }
        }
    }
    
    
}
