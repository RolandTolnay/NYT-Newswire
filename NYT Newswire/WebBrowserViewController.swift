//
//  WebBrowserViewController.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 13/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class WebBrowserViewController: UIViewController {

    @IBOutlet weak var browser: UIWebView!
    var urlString: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let urlString = self.urlString {
            let URLRequest = NSURLRequest(URL: NSURL(string: urlString)!)
            browser.loadRequest(URLRequest)
        }
    }
    @IBAction func refresh(sender: UIBarButtonItem) {
        browser.reload()
    }
    @IBAction func previousPage(sender: UIBarButtonItem) {
        browser.goBack()
    }
    @IBAction func nextPage(sender: UIBarButtonItem) {
        browser.goForward()
    }
}
