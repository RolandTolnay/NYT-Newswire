//
//  TopStoryViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class TopStoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SaveTopStoryDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let service = Service.sharedInstance
    let dateFormatter = NSDateFormatter()
    
    var sectionName: String?
    var topStorySections = [TopStorySection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 86
        
        if let sectionName = self.sectionName {
            navigationItem.title = "Top stories: " + sectionName.capitalizedString
            activityIndicator.startAnimating()
            tableView.hidden = true
            service.getTopStorySection(sectionName) {
                topStorySections in
                self.topStorySections = topStorySections
                self.tableView.hidden = false
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: Tableview datasource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return topStorySections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topStorySections[section].items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "topStoryCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TopStoryTableViewCell
        
        let topStory = topStorySections[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = topStory.title
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.pubDateLabel.text = "Published: " + dateFormatter.stringFromDate(topStory.pubDate)
        if let thumbnailURL = topStory.thumbnailURL where !thumbnailURL.isEmpty {
            cell.thumbnailImageView.downloadedFrom(link: thumbnailURL, contentMode: .ScaleAspectFit)
        } else {
            cell.thumbnailImageView.image = UIImage(named: "noThumbnail")
        }

        cell.delegate = self
        cell.favoriteButton.selected = service.isTopStorySaved(topStory)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return topStorySections[section].sectionName
    }
    
    //MARK: Saving top stories
    
    func saveTopStory(sender: TopStoryTableViewCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let topStoryToSave = topStorySections[indexPath.section].items[indexPath.row]
            print("Top story to save: \(topStoryToSave)")
            service.saveTopStory(topStoryToSave)
        }
    }
    
    func removeTopStory(sender: TopStoryTableViewCell) {
        if let indexPath = tableView.indexPathForCell(sender) {
            let topStoryToRemove = topStorySections[indexPath.section].items[indexPath.row]
            print("Top story to remove: \(topStoryToRemove)")
            service.removeTopStory(topStoryToRemove)
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopStoryDetailSegue" {
            let topStoryDetailViewController = segue.destinationViewController as! NewswireDetailViewController
            if let selectedTopStoryCell = sender as? TopStoryTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedTopStoryCell)!
                let selectedTopStory = topStorySections[indexPath.section].items[indexPath.row]
                topStoryDetailViewController.newswireItem = selectedTopStory
            }
        }
        
    }
    
    
}
