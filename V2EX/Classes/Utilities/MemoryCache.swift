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
    
    static func setReply(topicID topicID: Int, content: String) {
        cache.setObject(content, forKey: keyForReply(topicID: topicID))
    }
    
    static func getReply(topicID topicID: Int) -> String? {
        return cache.objectForKey(keyForReply(topicID: topicID)) as? String
    }
    
    static func removeReply(topicID topicID: Int) {
        cache.removeObjectForKey(keyForReply(topicID: topicID))
    }
    
    private static func keyForReply(topicID topicID: Int) -> String {
        return "topic[\(topicID)]_reply"
    }
    
    // TODO: Remove when release
    static func setLoginFailureHTML(html: String) {
        cache.setObject(html, forKey: "login_failure_html")
    }
    
    static func getLoginFailureHTML() -> String? {
        return cache.objectForKey("login_failure_html") as? String
    }
}