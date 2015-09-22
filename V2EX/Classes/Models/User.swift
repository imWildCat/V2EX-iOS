//
//  User.swift
//  V2EX
//
//  Created by WildCat on 11/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct User {
    
    var name: String
    var avatarURI: String
    var website: String?
    var twitter: String?
    var github: String?
    var createdAt: String?
    
    var liveness: Int?
    var id: Int?
    var company: String?
    var introduction: String?
    
    // Action token to support 
    var actionToken: String?
    var isBlocked: Bool = false
    var isFollowed: Bool = false
    
    init(name: String?, avatarURI: String? = nil, website: String? = nil, twitter: String? = nil, github: String? = nil, createdAt: String? = nil, liveness: String? = nil, id: String? = nil, company: String? = nil, introduction: String? = nil) {
        self.name = name ?? ""
        self.avatarURI = avatarURI ?? ""
        self.website = website
        self.twitter = twitter
        self.github = github
        self.createdAt = createdAt
        
        self.liveness = Int(liveness ?? "")
        self.id = Int(id ?? "")
        self.company = company
        self.introduction = introduction
    }
    
//    init(username: String) {
//        self.init(username: username, avatar: nil, website: nil, twitter: nil, github: nil, created_at: nil)
//    }
    
}