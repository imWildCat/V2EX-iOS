//
//  Reply.swift
//  V2EX
//
//  Created by WildCat on 19/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation
import hpple

struct Reply {
    
    var id: Int
    var author: User
    var time: String
    var appreciationsCount: Int
    var floor: Int
    var content: String
    var relatedTopic: Topic?
    
    var isAppreciated: Bool = false
    
    var appreciatingReplyToken: String?
    
    init(id: Int?, author: User, time: String?, appreciationsCount: Int?, floor: Int?, content: String?, relatedTopic: Topic? = nil) {
        self.id = id ?? 0
        self.author = author
        self.time = time ?? ""
        self.appreciationsCount = appreciationsCount ?? 0
        self.floor = floor ?? 0
        self.content = content ?? ""
        self.relatedTopic = relatedTopic
    }
    
    mutating func setContent(content: String?) {
        self.content = content ?? ""
    }
    
    static func listFromTopic(HTMLData: AnyObject?) -> [Reply] {
        var replies = [Reply]()
        
        let doc = TFHpple(HTMLObject: HTMLData)
        
        let elements = doc.searchWithXPathQuery("//div[@id='Main']/div[4]/div[@id and @class='cell' or @class='inner']") as! [TFHppleElement]
        
        for element in elements {
            let replyId = (element["id"] as! String?)?.match("r_(\\d{1,10})")?[1]
            let content = element.searchFirst("//div[@class='reply_content']")?.raw
            
            let authorAvatarURI = element.searchFirst("//td[1]/img")?.attr("src")
            let authorName = element.searchFirst("//td[@width='auto']/strong/a")?.text()
            let author = User(name: authorName, avatarURI: authorAvatarURI)
            
            let time = element.searchFirst("//td[@width='auto']/span[@class='fade small']")?.text()
            
            let floor = element.searchFirst("//td[@width='auto']/div[@class='fr']/span[@class='no']")?.text().toInt()
            
            let appreciationsCount = element.searchFirst("//td[@width='auto']/span[@class='small fade']")?.text()?.stringByReplacingOccurrencesOfString("♥ ", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil).toInt()
            
            var reply = Reply(id: replyId?.toInt(), author: author, time: time, appreciationsCount: appreciationsCount, floor: floor, content: content)
            
            if let thankElement = element.searchFirst("//div[@class='thank_area']//a[text()='感谢回复者']") {
                let token = thankElement.attr("onclick")?.match("thankReply\\(\\d+, '(\\w+)'\\)")?[1]
                reply.appreciatingReplyToken = token
            } else if let alreadyThankElement = element.searchFirst("//div[@class='thank_area thanked']") {
                reply.isAppreciated = true
            }
            
            replies.append(reply)
        }
        
        return replies
    }
}