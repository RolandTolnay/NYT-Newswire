//
//  NewswireViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 13/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class NewswireViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //MARK: Properties
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let service = Service.sharedInstance
    let dateFormatter = NSDateFormatter()
    
    var newswireSections = [NewswireSection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 86
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        self.tableView.addSubview(self.refreshControl)
        
        activityIndicator.startAnimating()
        self.tableView.hidden = true
        service.getNewswireSections() {
            newswireSections in
            self.newswireSections = newswireSections
            self.tableView.hidden = false
            self.activityIndicator.stopAnimating()
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return newswireSections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newswireSections[section].items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "newswireItemCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! NewswireItemTableViewCell
        
        let newswireItem = newswireSections[indexPath.section].items[indexPath.row]
        cell.titleLabel.text = newswireItem.title
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.pubDateLabel.text = "Published: " + dateFormatter.stringFromDate(newswireItem.pubDate)
        if let thumbnailURL = newswireItem.thumbnailURL where !thumbnailURL.isEmpty {
            cell.thumbnailImageView.downloadedFrom(link: thumbnailURL, contentMode: .ScaleAspectFit)
        } else {
            cell.thumbnailImageView.image = UIImage(named: "noThumbnail")
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return newswireSections[section].sectionName
    }
    
    //MARK: Refresh control
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        
        return refreshControl
    }()
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        service.getNewswireSections() {
            newswireSections in
            self.newswireSections = newswireSections
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }

    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showNewswireDetailSegue" {
            let newswireDetailViewController = segue.destinationViewController as! NewswireDetailViewController
            if let selectedNewswireCell = sender as? NewswireItemTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedNewswireCell)!
                let selectedNewswireItem = newswireSections[indexPath.section].items[indexPath.row]
                newswireDetailViewController.newswireItem = selectedNewswireItem
            }
        }
    }
    
}
