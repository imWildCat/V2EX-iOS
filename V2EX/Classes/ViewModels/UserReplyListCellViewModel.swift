//
//  UserReplyTopicViewCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 22/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

struct UserReplyListCellViewModel {

    var replyContent, topicTitle, authorName, time: String
    
    init(reply: Reply) {
        self.replyContent = reply.content
        self.topicTitle = reply.relatedTopic?.title ?? "未知标题"
        self.authorName = reply.relatedTopic?.author?.name ?? "未知用户"
        self.time = reply.time
    }
    
}