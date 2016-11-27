//
//  TopStory.swift
//  NYT Newswire
//
//  Created by Roland Tolnay on 14/12/15.
//  Copyright © 2015 Roland Tolnay. All rights reserved.
//

import UIKit

class TopStory: NewswireItem {
    
}

class TopStorySection: Equatable {
    
    var sectionName: String
    var items: [TopStory]
    
    init(sectionName: String, items: [TopStory]){
        self.sectionName = sectionName
        self.items = items
    }
}

//MARK: Equatable

func ==(lhs: TopStorySection, rhs: TopStorySection) -> Bool {
    return lhs.sectionName == rhs.sectionName && lhs.items == rhs.items
}