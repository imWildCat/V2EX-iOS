//
//  Topic.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

class Topic {
    
    var id: Int
    var title: String
    var repliesCount: Int
    var createdAt: String // TODO: remove device included
    
    var node: Node?
    var author: User?
    
    var content: String
    
    var appreciationCount: Int
    var favoriteCount: Int
    
    var favoriteLink: String
    
    init(id: Int?, title: String?, node: Node?, author: User?, repliesCount: Int? = nil, createdAt: String? = nil, content: String? = nil, appreciationCount: Int = 0, favoriteCount: Int = 0, favoriteLink: String? = nil) {
        self.id = id ?? 0
        self.title = title ?? "[未知标题]"
        self.repliesCount = repliesCount ?? 0
        self.author = author ?? nil
        self.createdAt = createdAt ?? ""
        self.node = node ?? nil
        self.content = content ?? ""
        self.appreciationCount = appreciationCount
        self.favoriteCount = favoriteCount
        self.favoriteLink = favoriteLink ?? ""
    }
    
//    init(id: Int?, title: String?, repliesCount: Int? = nil, author: User? = nil, createdAt: String? = nil, node: Node? = nil, favoriteLink: String? = nil) {
//        self.init(id: id, title: title, repliesCount: repliesCount, author: author, createdAt: createdAt, node: node)
//    }

    
    
    
    class func listFromTab(HTMLData: AnyObject?) -> [Topic] {
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
            var topicCreatedAt: String?
            topicCreatedAt = topicMetaElement?.raw.match("  •  ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)  •  最后回复来自")?[1]
            // handle topic with no reply
            if topicCreatedAt == nil {
                topicCreatedAt = topicMetaElement?.raw.match("  •  ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)")?[1]
            }
            
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
                node: Node(name: nodeName, slug: nodeSlug),
                author: User(
                    name: authorName,
                    avatarURI: avatarURI
                ),
                repliesCount: repliesCount,
                createdAt: topicCreatedAt
            )
            
            topics.append(topic)
        }
        
        return topics
    }
    
    class func singleTopic(HTMLData: AnyObject?) -> Topic {
        let doc = TFHpple(HTMLObject: HTMLData)
        
        let topicMetaElement = doc.searchWithXPathQuery("//div[@id='Main']//div[@class='box']/div[@class='header']").first as TFHppleElement?
        let topicTitle = topicMetaElement?.searchFirst("//h1")?.text()
        let topicId = (topicMetaElement?.searchFirst("//div[@class='votes']")?["id"] as String?)?.match("topic_(\\d+)_votes")?[1]
        let repliesCount = doc.searchFirst("//div[@id='Main']//div[@class='box']/div[@class='cell']/span[@class='gray']")?.raw.match("(\\d+) 回复")?[1]
        let topicContent = doc.searchFirst("//div[@id='Main']//div[@class='box']//div[@class='topic_content']")?.raw
        let topicCreatedAt = topicMetaElement?.searchFirst("//small[@class='gray']")?.text().match(" · ([a-zA-Z0-9 \\u4e00-\\u9fa5]+) ·")?[1]
        
        let nodeElement = topicMetaElement?.searchFirst("//a[3]")
        let nodeName = nodeElement?.text()
        let nodeSlug = (nodeElement?["href"] as String?)?.match("/go/(\\w{1,31})")?[1]
       
        let authorName = topicMetaElement?.searchFirst("//small[@class='gray']/a")?.text()
        let authorAvatarURI = topicMetaElement?.searchFirst("//div[@class='fr']/a/img")?["src"] as String?
        
        let topicOtherInfo = doc.searchFirst("//div[@id='Main']/div[@class='box']/div[@class='topic_buttons']/div")?.text()
        // TODO: implement it when implement login
        let appreciationCount = topicOtherInfo?.match("(\\d+) 人感谢")?[1].toInt() ?? 0
        let favCount = topicOtherInfo?.match("(\\d+) 人收藏")?[1].toInt() ?? 0

        println(topicOtherInfo)

        
        let favLink = doc.searchFirst("//div[@id='Main']/div[@class='box']/div[@class='topic_buttons']/a[@class='tb']")?["href"] as String?
        
        return Topic(id: topicId?.toInt(), title: topicTitle, node: Node(name: nodeName, slug: nodeSlug), author: User(name: authorName, avatarURI: authorAvatarURI), repliesCount: repliesCount?.toInt(), createdAt: topicCreatedAt, content: topicContent, appreciationCount: appreciationCount, favoriteCount: favCount, favoriteLink: favLink)
    }
    
}