//
//  UserTopicCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 22/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

struct UserTopicListCellViewModel {
    var topicTitle, nodeName, time, replyCount: String
    
    init(topic: Topic) {
        self.topicTitle = topic.title
        self.nodeName = topic.node?.name ?? ""
        self.time = topic.createdAt + "前"
        self.replyCount = topic.replyCount.description
    }
    
}