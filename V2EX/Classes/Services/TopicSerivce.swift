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
        
        V2EXNetworking.get("", parameters: ["tab": tabSlug]).responseString{ res in

            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                let topics = Topic.listFromTab(value)
                response?(result: NetworkingResult<[Topic]>.Success(topics))
            }
        }
    }
    
    class func getList(nodeSlug nodeSlug: String, page: Int = 1, response: ((result: NetworkingResult<NodePage>) -> Void)?) {
        
        V2EXNetworking.get("go/\(nodeSlug)?p=\(page)").responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                SessionService.showNotificationWhileCountIsNotZero(value)
                
                let topics = Topic.listFromNode(value)
                
                let titleHTML = TFHpple(HTMLStringOptional: value).searchFirst("//title")?.raw
                let nodeName = titleHTML?.match("› ([a-zA-Z0-9 \\u4e00-\\u9fa5]+)</title>")?[1]
                
                if nodeName == "登录" || topics.count == 0 {
                    let authRequiredError = V2EXError.AuthRequired.foundationError
                    response?(result: NetworkingResult.Failure(res.response, authRequiredError))
                } else {
                    let doc = TFHpple(HTMLString: value)
                    let (currentPage, totalPage) = self.handlePageNumberFromDocument(doc)
                    let nodePage = NodePage(nodeName: nodeName, topics: topics, currentPage: currentPage, totalPage: totalPage)
                    response?(result: NetworkingResult<NodePage>.Success(nodePage))
                }
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
        
        V2EXNetworking.get(url, parameters: nil).responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                SessionService.showNotificationWhileCountIsNotZero(value)
                
                let topic = Topic.singleTopic(value)
                let replies = Reply.listFromTopic(value)
                
                let doc = TFHpple(HTMLStringOptional: value)
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
        
    }
    
    class func topicListOfUser(user: String, page: Int = 1, response: ((result: NetworkingResult<TopicListPage>) -> Void)?) {
        
        V2EXNetworking.get("member/" + user + "/topics", parameters: ["p": page]).responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                SessionService.showNotificationWhileCountIsNotZero(value)
                
                let doc = TFHpple(HTMLStringOptional: value)
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
                
                let (currentPage, totalPage) = self.handlePageNumberFromDocument(doc)
            
                let topicListPage = TopicListPage(topics: topics, currentPage: currentPage, totalPage: totalPage)
                
                response?(result: NetworkingResult<TopicListPage>.Success(topicListPage))
            }
        }
    }
    
    static func handlePageNumberFromDocument(doc: TFHpple) -> (Int, Int) {
        // Check if there are more pages
        let pageCurrentElement = doc.searchFirst("//div[@id='Main']//a[@class='page_current']")
        let currentPage = Int(pageCurrentElement?.text() ?? "1") ?? 1
        let totalPage = Int(doc.searchElements("//div[@id='Main']//a[@class='page_normal']").last?.text() ??  "1") ?? 1
                
        return (currentPage, totalPage)
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
        
        V2EXNetworking.get("member/" + user + "/replies", parameters: ["p": page]).responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                SessionService.showNotificationWhileCountIsNotZero(value)
                
                let doc = TFHpple(HTMLStringOptional: value)
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
    }
    
    class func favoriteTopics(page: Int = 1, response: ((result: NetworkingResult<TopicListPage>) -> Void)?) {
        V2EXNetworking.get("my/topics").responseString { res in
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Favorite Topic: Success", description: error.description)
            case .Success(let value):
                let doc = TFHpple(HTMLStringOptional: value)
                let topics = Topic.listFromTab(value)
                let (currentPage, totalPage) = self.handlePageNumberFromDocument(doc)
                let topicListPage = TopicListPage(topics: topics, currentPage: currentPage, totalPage: totalPage)
                response?(result: NetworkingResult<TopicListPage>.Success(topicListPage))
            }
        }
    }
    
    class func createTopic(onceCode onceCode: String, nodeSlug: String, title: String, content: String, response: ((result: NetworkingResult<Topic?>) -> Void)?) {
        V2EXAnalytics.event("Create Topic: Request")
        V2EXNetworking.post("new/\(nodeSlug)", parameters: ["once" : onceCode, "title": title, "content": content]).responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Create Topic: Failure", description: error.description)
            case .Success(let value):
                SessionService.showNotificationWhileCountIsNotZero(value)
                
                var topic: Topic?
                
                topic = Topic.singleTopic(value)
                topic?.isNew = true
                
                if topic?.id == 0 {
                    topic = nil
                }
                
                let doc = TFHpple(HTMLStringOptional: value)
                if let problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text() {
                    response?(result: NetworkingResult<Topic?>.Failure(res.response, V2EXError.OtherProblem(problemMessage).foundationError))
                    V2EXAnalytics.event("Create Topic: Request", description: problemMessage)
                } else {
                    response?(result: NetworkingResult<Topic?>.Success(topic))
                    V2EXAnalytics.event("Create Topic: Success")
                }
            }
            }
    }
    
    class func replyTopic(onceCode onceCode: String, topicID: Int, content: String, response: ((result: NetworkingResult<Bool>) -> Void)?) {
        V2EXAnalytics.event("Reply Topic: Request")
        V2EXNetworking.post("t/\(topicID)", parameters: [
                "content": content,
                "once": onceCode
            ]).responseString { res in
                
                switch res.result {
                case .Failure(let error):
                    if res.response?.statusCode == 403 {
                        response?(result: NetworkingResult.Failure(res.response, V2EXError.AuthRequired.foundationError))
                        V2EXAnalytics.event("Reply Topic: Request", description: V2EXError.AuthRequired.description)
                    } else {
                        response?(result: NetworkingResult.Failure(res.response, error))
                        V2EXAnalytics.event("Reply Topic: Request", description: error.description)
                    }
                    
                case .Success(let value):
                    SessionService.showNotificationWhileCountIsNotZero(value)
                    let doc = TFHpple(HTMLStringOptional: value)
                    let problemMessage = doc.searchFirst("//div[@class='problem']/ul/li")?.text()
                    if let problemMessage = problemMessage {
                        response?(result: NetworkingResult.Failure(res.response, V2EXError.OtherProblem(problemMessage).foundationError))
                        V2EXAnalytics.event("Reply Topic: Request", description: problemMessage)
                    } else {
                        response?(result: NetworkingResult<Bool>.Success(true))
                        V2EXAnalytics.event("Reply Topic: Success")
                    }
                }
        }
    }
    
}
