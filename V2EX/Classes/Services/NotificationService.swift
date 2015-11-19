//
//  NotificationService.swift
//  V2EX
//
//  Created by WildCat on 04/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import hpple

class NotificationService {
    
    class func get(page: Int = 1, response: ((result: NetworkingResult<[Notification]>) -> Void)? = nil) {
        V2EXNetworking.get("notifications", parameters: ["p": page]).responseString {
            res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                let doc = TFHpple(HTMLStringOptional: value)
                
                let rows = doc.searchElements("//div[@id='Main']//div[@class='box']//div[@class='cell']/table[1]//tr")
                
                var notifications = [Notification]()
                
                for row in rows {
                    let avatarURI = row.searchFirst("//td[1]//img/@src")?.content
                    let username = row.searchFirst("//td[2]/span[@class='fade']/a[1]/strong")?.content
                    let time = row.searchFirst("//td[2]//span[@class='snow']")?.content.replace(" ago", withString: "")
                    let action = row.searchFirst("//td[2]/span[@class='fade']")?.text()?.replace(" ", withString: "") ?? "" // could determine which type it is by this(在, 在回复, 感谢了... , 收藏)
                    let relatedTopicID = row.searchFirst("//td[2]/span[@class='fade']/a[2]")?.attr("href")?.match("/t/(\\d{1,9})#")?[1]
                    let relatedTopicTitle = row.searchFirst("//td[2]/span[@class='fade']/a[2]")?.content
                    let relatedContent = row.searchFirst("//div[@class='payload']")?.content
                    
                    // create a notification
                    var notificationType: Notification.NotificationType!
                    print("Action: \(action)")
                    switch action {
                    case "在":
                        notificationType = .Reply
                    case "收藏了你发布的主题›":
                        notificationType = .Favorite
                    case "感谢了你发布的主题":
                        notificationType = .AppreciationForTopic
                    case "感谢了你在主题›":
                        notificationType = .AppreciationForReply
                    case "在创建主题":
                        notificationType = .AtInTopic
                    case "在回复":
                        notificationType = .AtInReply
                    default:
                        notificationType = .UnDefined
                    }
                    
                    let relatedUser = User(name: username, avatarURI: avatarURI)
                    let relatedTopic = Topic(id: relatedTopicID, title: relatedTopicTitle, node: nil, author: nil)
                    
                    let notification = Notification(type: notificationType, relatedUser: relatedUser, relatedTopic: relatedTopic, relatedContent: relatedContent, time: time)
                    
                    notifications.append(notification)
                }
                
                response?(result: NetworkingResult<[Notification]>.Success(notifications))
            }
        }
    }
}