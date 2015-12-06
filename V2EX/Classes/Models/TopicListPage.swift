//
//  TopicListPage.swift
//  V2EX
//
//  Created by WildCat on 12/6/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

struct TopicListPage: Pageable {
    let topics: [Topic]
    let currentPage: Int
    let totalPage: Int
}