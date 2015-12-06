//
//  Pageable.swift
//  V2EX
//
//  Created by WildCat on 12/6/15.
//  Copyright © 2015 WildCat. All rights reserved.
//

import Foundation

protocol Pageable {
    var currentPage: Int { get }
    var totalPage: Int { get }
}

extension Pageable {
    var hasMorePage: Bool {
        return currentPage < totalPage
    }
    var isLastPage: Bool {
        return currentPage >= totalPage
    }
}