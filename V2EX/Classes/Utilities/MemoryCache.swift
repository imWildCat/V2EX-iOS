//
//  MemoryCache.swift
//  V2EX
//
//  Created by WildCat on 8/15/15.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

private let cache = NSCache()

struct MemoryCache {
    
    static func setReply(#topicID: Int, content: String) {
        cache.setObject(content, forKey: keyForReply(topicID: topicID))
    }
    
    static func getReply(#topicID: Int) -> String? {
        return cache.objectForKey(keyForReply(topicID: topicID)) as? String
    }
    
    static func removeReply(#topicID: Int) {
        cache.removeObjectForKey(keyForReply(topicID: topicID))
    }
    
    private static func keyForReply(#topicID: Int) -> String {
        return "topic[\(topicID)]_reply"
    }
}