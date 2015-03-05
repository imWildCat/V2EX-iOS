//
//  TopicContentCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 10/01/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

struct TopicContentCellViewModel {
    var avatarURL, authorName, timeAgo, contentHTML: String
    
    
    init(topic: Topic) {
        // TODO: handle ssl or non-ssl setting
        avatarURL =  "https:" + (topic.author?.avatarURI ?? "")
        authorName = topic.author?.name ?? ""
        timeAgo = topic.createdAt
        contentHTML = topic.content
    }
    
    init(reply: Reply) {
        avatarURL = "https:" + (reply.author.avatarURI ?? "")
        authorName = reply.author.name
        timeAgo = reply.time
        contentHTML = reply.content
    }
}