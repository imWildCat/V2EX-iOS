//
//  User.swift
//  V2EX
//
//  Created by WildCat on 11/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct User {
    
    var username: String
    var avatarURI: String
    var website: String?
    var twitter: String?
    var github: String?
    var createdAt: Int?
    
    init(username: String?, avatarURI: String? = nil, website: String? = nil, twitter: String? = nil, github: String? = nil, createdAt: Int? = nil) {
        self.username = username ?? ""
        self.avatarURI = avatarURI ?? ""
        self.website = website
        self.twitter = twitter
        self.github = github
        self.createdAt = createdAt
    }
    
//    init(username: String) {
//        self.init(username: username, avatar: nil, website: nil, twitter: nil, github: nil, created_at: nil)
//    }
    
}