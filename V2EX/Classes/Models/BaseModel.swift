//
//  BaseModel.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct BaseModel: Storable, Equatable {
    
    var id: Int
    
    var createdAt: Int;
    var expriresIn: Int;
    
    init() {
        fatalError("This is an abstract model!")
    }
    
    var key: String {
        get {
            return String(id)
        }
    }
    
    
    
    
}

// MARK: BaseModel - Equatable

func ==(lhs: BaseModel, rhs: BaseModel) -> Bool {
    return lhs.key == rhs.key
}