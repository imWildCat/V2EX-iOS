//
//  TopicListCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 15/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct TopicListCellViewModel {
    var title, avatarURI, authorName, time, repliesCount: String
    var nodeName: String?
    
    init(topic: Topic) {
        self.title = topic.title
        self.avatarURI = topic.author?.avatarURI ?? ""
        self.authorName = topic.author?.name ?? ""
        self.time = topic.createdAt
        self.repliesCount = String(topic.replyCount)
        
        self.nodeName = topic.node?.name
    }
}