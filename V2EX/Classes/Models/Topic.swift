//
//  Topic.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

struct Topic {
    
    var id: Int
    var title: String
    var repliesCount: Int
    var createdAt: String
    
    var node: Node?
    var author: User?
    
    init(id: Int?, title: String?, repliesCount: Int? = nil, author: User? = nil, createdAt: String? = nil, node: Node? = nil) {
        self.id = id ?? 0
        self.title = title ?? "[未知标题]"
        self.repliesCount = repliesCount ?? 0
        self.author = author ?? nil
        self.createdAt = createdAt ?? ""
        self.node = node ?? nil
    }
    
    static func listFromTab(HTMLData: AnyObject?) -> [Topic] {
        var topics = [Topic]()
        
        let doc = TFHpple(HTMLObject: HTMLData)
        
        let elements = doc.searchWithXPathQuery("//div[@id='Main']//div[@class='box']/div[@class='cell item']/table") as [TFHppleElement]
        
        for element in elements {
            
            let titleElement = element.searchFirst("//td[3]/span[@class='item_title']/a")
            let topicTitle = titleElement?.text()
            let topicId = ((titleElement?["href"] as String?)?.match("/t/(\\d{1,9})#")?[1])?.toInt()
            
            let repliesCountElement = element.searchFirst("//td[4]/a")
            let repliesCount = repliesCountElement?.text().toInt()
            
            let topicMetaElement = element.searchFirst("//td[3]/span[@class='small fade']")
            // the space of the following regx is not regular
            let topicCreatedAt = topicMetaElement?.raw.match("  •  ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)  •  最后回复来自")?[1]
            // TODO: handle topic with no reply
            
            let nodeElement = element.searchFirst("//td[3]/span[@class='small fade']/a[@class='node']")
            let nodeName = nodeElement?.text()
            let nodeSlug = (nodeElement?["href"] as String?)?.match("/go/(\\w{1,31})")?[1]
            
            let authorElement = element.searchFirst("//td[3]/span[@class='small fade']/strong/a")
            let authorName = authorElement?.text()
            
            let avatarElement = element.searchFirst("//td[1]/a/img[@class='avatar']")
            let avatarURI = avatarElement?["src"] as String?
            
            let topic = Topic(
                id: topicId,
                title: topicTitle,
                repliesCount: repliesCount,
                author: User(
                    username: authorName,
                    avatarURI: avatarURI
                ),
                createdAt: topicCreatedAt,
                node: Node(name: nodeName, slug: nodeSlug)
            )
            
            topics.append(topic)
        }
        
        return topics
    }
    
}