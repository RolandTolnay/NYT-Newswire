//
//  TopStoriesSectionViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class TopStoriesSectionViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    let sections = [
        "home", "world", "national", "politics", "ny region", "business", "opinion", "technology",
        "science", "health", "sports", "arts", "fashion", "dining", "travel", "magazine", "real estate"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    override func viewWillAppear(animated: Bool) {
        //reset title 
        navigationItem.title = "Top Story Sections"
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let reuseIdentifier = "topStoriesSectionCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier, forIndexPath: indexPath) as! TopStoriesSectionTableViewCell
        
        let sectionName = sections[indexPath.row].capitalizedString
        cell.sectionNameLabel.text = sectionName
        
        return cell
    }
    
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopStoriesForSectionSegue" {
            let topStoryViewController = segue.destinationViewController as! TopStoryViewController
            if let selectedTopStorySectionCell = sender as? TopStoriesSectionTableViewCell {
                let indexPath = tableView.indexPathForCell(selectedTopStorySectionCell)!
                let selectedTopStorySection = sections[indexPath.row]
                topStoryViewController.sectionName = selectedTopStorySection.stringByReplacingOccurrencesOfString(" ", withString: "")
                //change the 'back' button title to default
                navigationItem.title = nil
            }
        }
    }
    

}
