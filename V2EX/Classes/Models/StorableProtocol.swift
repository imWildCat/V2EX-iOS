//
//  StorableProtocol.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

protocol Storable/*: Hashable*/ {
    var key: String { get }
    
//    func save(expiresIn: UInt);
}

extension User {
    
}