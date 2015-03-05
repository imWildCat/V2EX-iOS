//
//  TopicTitleCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 09/01/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

struct TopicTitleCellViewModel {
    var title: String
    
    init(topic: Topic) {
        self.title = topic.title
    }
    
}