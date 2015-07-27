//
//  TopicSerivce.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation
import hpple

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
    class func getList(#tabSlug: String, response: ((error: NSError?, topics: [Topic]) -> Void)?) {

        V2EXNetworking.get("", parameters: ["tab": tabSlug]).response { (_, _, data, error) in
            
            let topics = Topic.listFromTab(data)
            
            response?(error: error, topics: topics)
        }
    }
    
    class func getList(#nodeSlug: String, page: Int = 1, response: ((error: NSError?, topics: [Topic], nodeName: String?) -> Void)?) {
        
        V2EXNetworking.get("go/\(nodeSlug)?p=\(page)").response { (_, _, data, error) in
            
            let topics = Topic.listFromNode(data)
            
            let titleHTML = TFHpple(HTMLObject: data).searchFirst("//title")?.raw
            let nodeName = titleHTML?.match("› ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)</title>")?[1]
            
            response?(error: error, topics: topics, nodeName: nodeName)
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
                let nodeSlug = (nodeElement?["href"] as? String)?.match("/go/(\\w{1,31})")?[1]
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
    
    class func favoriteTopics(page: Int = 1, response: ((error: NSError?, topics: [Topic], totalCount: Int) -> Void)?) {
        V2EXNetworking.get("my/topics").response { (_, _, data, error) in
            var topics = [Topic]()
            var favCount = 0
            
            if error == nil {
                let doc = TFHpple(HTMLObject: data)
                
                favCount = doc.searchFirst("//div[@id='Rightbar']//table[2]//span[@class='bigger'][2]")?.text().toInt() ?? 0
                
                topics = Topic.listFromTab(data)
            }
            
            response?(error: error, topics: topics, totalCount: favCount)
        }
    }
    
    class func createTopic(#onceCode: String, nodeSlug: String, title: String, content: String, response: ((error: NSError?, topic: Topic?, problemMessage: String?) -> Void)?) {
        V2EXNetworking.post("new/\(nodeSlug)", parameters: ["once" : onceCode, "title": title, "content": content]).response { (_, httpResponse, data, error) in
            
            var topic: Topic?
            var problemMessage: String?
            if (error == nil) {
                
//                let res = httpResponse!
//                let header = res.allHeaderFields
//                let loca = header["Location"] as? String
//                let contentType = res.allHeaderFields["Content-Type"] as? String
//                let date = res.allHeaderFields["Date"] as? String
//                println(header)
//                println(date ?? "nil")
//                println(contentType ?? "nil")
//                println(loca ?? "nil")
//                println(1)
//                let s = NSString(data: data as! NSData, encoding: NSUTF8StringEncoding)
//                println(s ?? "content is nil")
//                println(http)
//                if let locationString = httpResponse?.allHeaderFields["Location"] as? String {
//                    let topicID = locationString.match("/t/(\\d{1,9})#")?[1].toInt()
//                }
                
//                    let e = doc.searchFirst("//link[@rel='canonical']")
//                    let href = doc.searchFirst("//link[@rel='canonical']")?.attr("href")
//                    topicID = doc.searchFirst("//link[@rel='canonical']")?.attr("href")?.match("/t/(\\d{1,9})")?[1].toInt()
                
                topic = Topic.singleTopic(data)
                topic?.isNew = true
                
                if topic?.id == 0 {
                    topic = nil
                }
                
                if topic == nil {
                    let doc = TFHpple(HTMLObject: data)

                    problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text()
                }
            }
            
            response?(error: error, topic: topic, problemMessage: problemMessage)
        }
    }
    
    class func replyTopic(#onceCode: String, topicID: Int, content: String, response: ((error: NSError?, problemMessage: String?) -> Void)?) {
        V2EXNetworking.post("t/\(topicID)", parameters: [
                "content": content,
                "once": onceCode
            ]).response { (_, httpResponse, data, error) in
                
                let doc = TFHpple(HTMLObject: data)
                
                var problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text()
                
                if httpResponse?.statusCode == 403 {
                    problemMessage = "请登录"
                }
                
                if error != nil {
                    response?(error: error, problemMessage: nil)
                } else if let pMessage = problemMessage {
                    response?(error: nil, problemMessage: pMessage)
                } else {
                    response?(error: nil, problemMessage: nil)
                }
        }
    }
    
}
