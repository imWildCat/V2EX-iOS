//
//  User.swift
//  V2EX
//
//  Created by WildCat on 11/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct User {
    
    var id: Int
    var username: String
    var avatar: String?
    var website: String?
    var twitter: String?
    var github: String?
    var created_at: UInt?
    
    init(id: Int, username: String, avatar: String?, website: String?, twitter: String?, github: String?, created_at: UInt?) {
        self.id = id
        self.username = username
        self.avatar = avatar
        self.website = website
        self.twitter = twitter
        self.github = github
        self.created_at = created_at
    }
    
    init(id: Int, username: String) {
        self.init(id: id, username: username, avatar: nil, website: nil, twitter: nil, github: nil, created_at: nil)
    }
    
}