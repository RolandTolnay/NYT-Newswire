//
//  ArticleSearchViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 12/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class ArticleSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: Properties
    
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    @IBOutlet weak var noContentLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var articles = [Article]()
    let dateFormatter = NSDateFormatter()
    let service = Service.sharedInstance
    
    var pageCounter = 0
    var isLoadingContent = false
    
    //MARK: Init
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultsTableView.delegate = self
        resultsTableView.dataSource = self
        searchTextField.delegate = self
        
        resultsTableView.rowHeight = UITableViewAutomaticDimension
        resultsTableView.estimatedRowHeight = 65
        resultsTableView.scrollsToTop = true
        checkForContent()
    }
    
    override func viewWillAppear(animated: Bool) {
        noContentLabel.text = "Search New York Times articles from 1851 to today. Enter a phrase to search for in the textfield above."
        if articles.count == 0 {
            searchTextField.text = ""
        }
    }
    
    func checkForContent() {
        if articles.count == 0 {
            resultsTableView.hidden = true
            noContentLabel.hidden = false
        } else {
            resultsTableView.hidden = false
            noContentLabel.hidden = true
            //scroll to top
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.resultsTableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
    }
    
    //MARK: Textfield delegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        searchTextField.resignFirstResponder()
        
        if let searchString = searchTextField.text {
            if !searchString.isEmpty {
                activityIndicator.startAnimating()
                isLoadingContent = true
                resultsTableView.hidden = true
                noContentLabel.hidden = true
                service.getArticlesContainingString(searchString,pageNumber: "0") {
                    articles in
                    self.articles = articles
                    self.resultsTableView.hidden = false
                    self.activityIndicator.stopAnimating()
                    self.isLoadingContent = false
                    self.resultsTableView.reloadData()
                    self.checkForContent()
                    
                    if articles.count == 0 {
                        self.noContentLabel.text = "No matching articles found."
                    } else {
                        self.service.getArticlesContainingString(searchString,pageNumber: self.getNextPage()) {
                            articles in
                            self.articles += articles
                            self.resultsTableView.reloadData()
                        }
                    }
                }
            } else {
                articles = [Article]()
                checkForContent()
            }
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        searchTextField.textAlignment = .Left
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        searchTextField.textAlignment = .Center
    }
    
    //MARK: Tableview
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = "articleCell"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as! ArticleTableViewCell
        
        //array index out of range bug
        let article = articles[indexPath.row]
        
        cell.titleLabel.text = article.headline
        dateFormatter.dateFormat = "yyyy-MM-dd"
        cell.pubDateLabel.text = "Published: " + dateFormatter.stringFromDate(article.pubDate)
        
        let rowsLeftBeforeUpdate = 5
        if indexPath.row > (articles.count - rowsLeftBeforeUpdate) && !isLoadingContent {
            isLoadingContent = true
            service.getArticlesContainingString(searchTextField.text!,pageNumber: getNextPage()) {
                articles in
                if articles.count > 0 {
                    self.articles += articles
                    self.resultsTableView.reloadData()
                    self.isLoadingContent = false
                }
            }
        }
        
        return cell
    }
    
    func getNextPage() -> String {
        pageCounter++
        return pageCounter.description
    }
    
    //MARK: Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showArticleDetailSegue" {
            let articleDetailViewController = segue.destinationViewController as! ArticleDetailViewController
            if let selectedArticleCell = sender as? ArticleTableViewCell {
                let indexPath = resultsTableView.indexPathForCell(selectedArticleCell)!
                let selectedArticle = articles[indexPath.row]
                articleDetailViewController.article = selectedArticle
            }
        }
    }
    
    
}

