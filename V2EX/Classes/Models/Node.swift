//
//  Node.swift
//  V2EX
//
//  Created by WildCat on 15/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct Node {
    
    var name: String
    var slug: String
    
    init(name: String?, slug: String?) {
        self.name = name ?? ""
        self.slug = slug ?? ""
    }
    
}