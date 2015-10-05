//
//  TopicPage.swift
//  V2EX
//
//  Created by WildCat on 10/5/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

class TopicPage {
    var topic: Topic
    var replies: [Reply]
    var currentPage: Int
    var totalPage: Int
    
    init(topic: Topic, replies: [Reply], currentPage: Int = 1, totalPage: Int = 1) {
        self.topic = topic
        self.replies = replies
        self.currentPage = currentPage
        self.totalPage = totalPage
    }
}