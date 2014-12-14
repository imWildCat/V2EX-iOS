//
//  Topic.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct Topic {
    
    var id: UInt
    var title: String
    var author: User?
    
    init(id: UInt, title: String) {
        self.id = id
        self.title = title
    }
    
}