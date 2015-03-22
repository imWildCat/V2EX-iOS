//
//  TopicSerivce.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

//enum TabSlug: String {
//    case ALL = "all"
//    case HOT = "hot"
//    case R2  = "r2"
//    case QNA = "qna"
//    case CITY = "city"
//    case DEALS = "deals"
//    case JOBS = "jobs"
//    case APPLE = "apple"
//    case PLAY = "play"
//}

class TopicSerivce {
    class func getList(tabSlug: String, response: ((error: NSError?, topics: [Topic]) -> Void)?) {

        V2EXNetworking.get("", parameters: ["tab": tabSlug]).response { (_, _, data, error) in
            
            let topics = Topic.listFromTab(data)
            
            response?(error: error, topics: topics)
        }
    }
    
    class func singleTopic(id: Int, response: ((error: NSError?, topic: Topic, replies: [Reply]) -> Void)?) {
        
        V2EXNetworking.get("t/" + String(id), parameters: nil).response {
            (_, _, data, error) in
            let topic = Topic.singleTopic(data)
            let replies = Reply.listFromTopic(data)
            
            response?(error: error, topic: topic, replies: replies)
        }
        
    }
    
    class func topicListOf(#user: String, page: UInt = 1, reponse: ((error: NSError?, topics: [Topic]) -> Void)?) {
        
        V2EXNetworking.get("member/" + user + "/topics", parameters: ["p": page]).response { (_, _, data, error) in
            let doc = TFHpple(HTMLObject: data)
            let elements = doc.searchElements("//div[@id='Main']//div[@class='box']/div[@class='cell item']/table")
            
            var topics = [Topic]()
            
            for element in elements
            {
                let titleElement = element.searchFirst("//span[contains(concat(' ', normalize-space(@class), ' '), ' item_title ')]/a")
                let title = titleElement?.text()
                let id = titleElement?.attr("href")?.match("/t/(\\d{1,9})#")?[1]
                
                let replyCount = element.searchFirst("//td[@align='right']/a")?.text()
                let createdAt = element.searchFirst("//span[@class='small fade']")?.raw.match("•  ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)前")?[1]
                
                let nodeElement = element.searchFirst("//a[@class='node']")
                let nodeName = nodeElement?.text()
                let nodeSlug = (nodeElement?["href"] as String?)?.match("/go/(\\w{1,31})")?[1]
                topics.append(Topic(id: id, title: title, node: Node(name: nodeName, slug: nodeSlug), author: nil, replyCount: replyCount, createdAt: createdAt, content: nil))
            }
            
            reponse?(error: error, topics: topics)
        }
    }
    
    class func replyListOf(#user: String, page: Int = 1, response: ((error: NSError?, replies: [Reply]) -> Void)?) {
        
        V2EXNetworking.get("member/" + user + "/replies", parameters: ["p": page]).response { (_, _, data, error) in
            let doc = TFHpple(HTMLObject: data)
            let metaElements = doc.searchElements("//descendant-or-self::div[@id = 'Main']/descendant::div[contains(concat(' ', normalize-space(@class), ' '), ' box ')]/descendant::div[contains(concat(' ', normalize-space(@class), ' '), ' dock_area ')]")
            let contentElements = doc.searchElements("//descendant-or-self::div[@id = 'Main']/descendant::div[contains(concat(' ', normalize-space(@class), ' '), ' box ')]/descendant::div[contains(concat(' ', normalize-space(@class), ' '), ' inner ')]")
            
            var info = [[String: String?]]()
            
            for metaElement in metaElements {
                let topicElement = metaElement.searchFirst("//span[@class='gray']/a")
                let topicTitle = topicElement?.text()
                let topicID = topicElement?.attr("href")?.match("/t/(\\d{1,9})#")?[1]
                
                let topicAuthor = metaElement.searchFirst("//span[@class='gray']")?.raw.match("回复了 (\\w+) 创建的主题")?[1]
                
                let time = metaElement.searchFirst("//span[@class='fade']")?.text()
                
                info.append([
                    "topicID": topicID,
                    "topicTitle": topicTitle,
                    "topicAuthor": topicAuthor,
                    "time": time
                    ])
            }
            
            var replies = [Reply]()

            
            for (index, contentElement) in enumerate(contentElements)
            {
                if index < info.count {
                    let i = info[index]
                    
                    let content = contentElement.searchFirst("//descendant-or-self::div[contains(concat(' ', normalize-space(@class), ' '), ' reply_content ')]")?.raw.strippingHTML()
                    
                    let author = User(name: i["topicAuthor"] ?? "未知用户")
                    let topic = Topic(id: i["topicID"] ?? "0", title: i["topicTitle"] ?? "未知标题", node: nil, author: author)
                    
                    replies.append(Reply(id: nil, author: User(name: ""), time: i["time"] ?? "未知时间", appreciationsCount: nil, floor: nil, content: content, relatedTopic: topic))
                }
            }
            
            response?(error: error, replies: replies)
        }
    }
}
