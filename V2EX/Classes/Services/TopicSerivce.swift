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
    class func getList(tabSlug tabSlug: String, response: ((result: NetworkingResult<[Topic]>) -> Void)?) {
        
        V2EXNetworking.get("", parameters: ["tab": tabSlug]).responseString{ (req, res, ret) -> Void in

            if ret.isSuccess {
                let topics = Topic.listFromTab(ret.value)
                response?(result: NetworkingResult<[Topic]>.Success(topics))
            } else {
                response?(result: NetworkingResult.Failure(res, ret.error))
            }
        }
    }
    
    class func getList(nodeSlug nodeSlug: String, page: Int = 1, response: ((result: NetworkingResult<([Topic], String?)>) -> Void)?) {
        
        V2EXNetworking.get("go/\(nodeSlug)?p=\(page)").responseString { (httpRequest, httpResponse, ret) in
            
            if ret.isFailure {
                response?(result: NetworkingResult.Failure(httpResponse, ret.error))
            } else {
                SessionService.showNotificationWhileCountIsNotZero(ret.value)
                
                let topics = Topic.listFromNode(ret.value)
                
                let titleHTML = TFHpple(HTMLStringOptional: ret.value).searchFirst("//title")?.raw
                let nodeName = titleHTML?.match("› ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)</title>")?[1]
                
                if nodeName == "登录" {
                    let authRequiredError = V2EXError.AuthRequired.foundationError
                    response?(result: NetworkingResult.Failure(httpResponse, authRequiredError))
                    return
                }
                
                response?(result: NetworkingResult<([Topic], String?)>.Success((topics, nodeName)))
            }
        }
    }
    
    class func singleTopic(id: Int, page: Int? = nil, response: ((result: NetworkingResult<TopicPage>) -> Void)?) {
        
        let url: String = {
            if let p = page {
                return "t/" + String(id) + "?p=\(p)"
            } else {
                return "t/" + String(id)
            }
        }()
        
        V2EXNetworking.get(url, parameters: nil).responseString {
            (_, res, ret) in
            
            if ret.isFailure {
                response?(result: NetworkingResult.Failure(res, ret.error))
                return
            }
            
            SessionService.showNotificationWhileCountIsNotZero(ret.value)
            
            let topic = Topic.singleTopic(ret.value)
            let replies = Reply.listFromTopic(ret.value)
            
            let doc = TFHpple(HTMLStringOptional: ret.value)
            if let onceCodeString = doc.searchFirst("//input[@name='once']")?.attr("value") {
                SessionStorage.sharedStorage.onceCode = onceCodeString
            }
            
            if let reportJS = doc.searchFirst("//a[text()='报告这个主题']")?.attr("onclick") {
                let reportLink = reportJS.match("(report/topic/\\d+\\?t=\\d+)")?[1]
                topic.reportLink = reportLink
            } else if let _ = doc.searchFirst("//span[text()='你已对本主题进行了报告']") {
                topic.isReported = true
            }
            
            if let favRawLink = doc.searchFirst("//a[text()='加入收藏']")?.attr("href") {
                let favLink = favRawLink.match("(favorite/topic/\\d+\\?t=\\w+)")?[1]
                topic.favoriteLink = favLink
            } else if let unFavRawLink = doc.searchFirst("//a[text()='取消收藏']")?.attr("href") {
                let favLink = unFavRawLink.match("(unfavorite/topic/\\d+\\?t=\\w+)")?[1]
                topic.favoriteLink = favLink
                topic.isFavorited = true
            }
            
            if let appreciationString = doc.searchFirst("//div[@class='topic_buttons']//a[text()='感谢']")?.attr("onclick") {
                let token = appreciationString.match("thankTopic\\(\\d+, '(\\w+)'\\)")?[1]
                topic.appreciateToken = token
            } else if let _ = doc.searchFirst("//div[@class='topic_buttons']//span[text()='感谢已发送']") {
                topic.isAppreciated = true
            }
            
            var currentPage = 1
            var totalPage = 1
            if let currentPageElement = doc.searchFirst("//span[@class='page_current']") {
                currentPage = Int(currentPageElement.text()) ?? 1
                let lastPageElement = doc.searchFirst("(//a[@class='page_normal'])[last()]")
                totalPage = Int(lastPageElement?.text() ?? "") ?? 1
                if currentPage > totalPage {
                    totalPage = currentPage
                }
            }
            let topicPage = TopicPage(topic: topic, replies: replies, currentPage: currentPage, totalPage: totalPage ?? 1)
            response?(result: NetworkingResult<TopicPage>.Success(topicPage))
        }
        
    }
    
    class func topicListOf(user user: String, page: UInt = 1, response: ((result: NetworkingResult<[Topic]>) -> Void)?) {
        
        V2EXNetworking.get("member/" + user + "/topics", parameters: ["p": page]).responseString { (_, res, ret) in
            
            if ret.isFailure {
                response?(result: NetworkingResult.Failure(res, ret.error))
                return
            }
            
            SessionService.showNotificationWhileCountIsNotZero(ret.value)
            
            let doc = TFHpple(HTMLStringOptional: ret.value)
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
            
            response?(result: NetworkingResult<[Topic]>.Success(topics))
        }
    }
    
    struct ReplyList {
        var replies: [Reply]
        var hasNextPage: Bool
        
        init(replies: [Reply], hasNextPage: Bool) {
            self.replies = replies
            self.hasNextPage = hasNextPage
        }
    }
    
    class func replyListOf(user user: String, page: Int = 1, response: ((result: NetworkingResult<ReplyList>) -> Void)?) {
        
        V2EXNetworking.get("member/" + user + "/replies", parameters: ["p": page]).responseString { (httpRequest, httpResponse, ret) in
            
            if ret.isFailure {
                response?(result: NetworkingResult.Failure(httpResponse, ret.error))
            }
            
            SessionService.showNotificationWhileCountIsNotZero(ret.value)
            
            let doc = TFHpple(HTMLStringOptional: ret.value)
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

            
            for (index, contentElement) in contentElements.enumerate()
            {
                if index < info.count {
                    let i = info[index]
                    
                    let content = contentElement.searchFirst("//descendant-or-self::div[contains(concat(' ', normalize-space(@class), ' '), ' reply_content ')]")?.raw.strippingHTML()
                    
                    let author = User(name: i["topicAuthor"] ?? "未知用户")
                    let topic = Topic(id: i["topicID"] ?? "0", title: i["topicTitle"] ?? "未知标题", node: nil, author: author)
                    
                    replies.append(Reply(id: nil, author: User(name: ""), time: i["time"] ?? "未知时间", appreciationsCount: nil, floor: nil, content: content, relatedTopic: topic))
                }
            }
            
            var hasNextPage = false
            if let _ = doc.searchFirst("//input[@value='下一页 ›']") {
                hasNextPage = true
            }
            
            response?(result: NetworkingResult<ReplyList>.Success(ReplyList(replies: replies, hasNextPage: hasNextPage)))
        }
    }
    
    class func favoriteTopics(page: Int = 1, response: ((result: NetworkingResult<([Topic], Int)>) -> Void)?) {
        
        V2EXNetworking.get("my/topics").responseString { (req, res, ret) in
            
//            SessionService.showNotificationWhileCountIsNotZero(data)
            
            if ret.isSuccess {
                let doc = TFHpple(HTMLStringOptional: ret.value)
                let favCount = Int(doc.searchFirst("//div[@id='Rightbar']//table[2]//span[@class='bigger'][2]")?.text() ?? "") ?? 0
                
                let topics = Topic.listFromTab(ret.value)
                response?(result: NetworkingResult<([Topic], Int)>.Success(topics, favCount))
            } else {
                response?(result: NetworkingResult.Failure(res, ret.error))
            }
        }
    }
    
    class func createTopic(onceCode onceCode: String, nodeSlug: String, title: String, content: String, response: ((result: NetworkingResult<Topic?>) -> Void)?) {
        V2EXNetworking.post("new/\(nodeSlug)", parameters: ["once" : onceCode, "title": title, "content": content]).responseString { (_, res, ret) in
            
            SessionService.showNotificationWhileCountIsNotZero(ret.value)
            
            if ret.isSuccess {
                var topic: Topic?
                
                topic = Topic.singleTopic(ret.value)
                topic?.isNew = true
                
                if topic?.id == 0 {
                    topic = nil
                }
                
                let doc = TFHpple(HTMLStringOptional: ret.value)
                if let problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text() {
                    response?(result: NetworkingResult<Topic?>.Failure(res, V2EXError.OtherProblem(problemMessage).foundationError))
                } else {
                    response?(result: NetworkingResult<Topic?>.Success(topic))
                }
            } else {
                response?(result: NetworkingResult.Failure(res, ret.error))
            }
            
            
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
            }
    }
    
    class func replyTopic(onceCode onceCode: String, topicID: Int, content: String, response: ((result: NetworkingResult<Bool>) -> Void)?) {
        V2EXNetworking.post("t/\(topicID)", parameters: [
                "content": content,
                "once": onceCode
            ]).responseString { (req, res, ret) in
                
                SessionService.showNotificationWhileCountIsNotZero(ret.value)
                
                let doc = TFHpple(HTMLStringOptional: ret.value)
                
                let problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text()
                
                if ret.isSuccess {
                    response?(result: NetworkingResult<Bool>.Success(true))
                } else if res?.statusCode == 403 {
                    response?(result: NetworkingResult.Failure(res, V2EXError.AuthRequired.foundationError))
                } else if let problemMessage = problemMessage {
                    response?(result: NetworkingResult.Failure(res, V2EXError.OtherProblem(problemMessage).foundationError))
                } else {
                    response?(result: NetworkingResult.Failure(res, ret.error))
                }
        }
    }
    
}
