//
//  NodePage.swift
//  V2EX
//
//  Created by WildCat on 12/6/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

struct NodePage: Pageable {
    let nodeName: String?
    let topics: [Topic]
    let currentPage: Int
    let totalPage: Int
}