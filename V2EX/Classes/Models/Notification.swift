//
//  Notification.swift
//  V2EX
//
//  Created by WildCat on 04/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

struct Notification {
    
    enum NotificationType {
        case Reply
        case Favorite
        case AppreciationForTopic
        case AppreciationForReply
        case AtInTopic
        case AtInReply
        case UnDefined
    }
    
    var type: NotificationType
    var relatedUser: User
    var relatedTopic: Topic
    var relatedContent: String?
    var time: String
    
    init(type: NotificationType, relatedUser: User, relatedTopic: Topic, relatedContent: String? = nil, time: String? = nil) {
        self.type = type
        self.relatedUser = relatedUser
        self.relatedTopic = relatedTopic
        self.relatedContent = relatedContent
        self.time = time ?? ""
    }
    
}