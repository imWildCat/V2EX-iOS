//
//  UserNotificationListCellViewModel.swift
//  V2EX
//
//  Created by WildCat on 11/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

struct UserNotificationListCellViewModel {
//    var title: NSAttributedString
    var title: String
    var avatarURI, time: String
    var relatedContent: String?
    
    init(notification: Notification) {
        self.avatarURI = notification.relatedUser.avatarURI
        
//        let titleData = UserNotificationListCellViewModel.buildTitle(notification).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
//        self.title =  NSAttributedString(data: titleData, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil, error: nil) ?? NSAttributedString(string: "构建标题失败，请联系 App 作者。")
        self.title = UserNotificationListCellViewModel.buildTitle(notification)
        
        self.relatedContent = notification.relatedContent
        self.time = notification.time
    }
    
    private static func buildTitle(notification: Notification) -> String {
        switch notification.type {
        case .Reply:
//            return "<b>\(notification.relatedUser.name)</b> 回复了你的话题 <b>\(notification.relatedTopic.title)</b>"
            return "\(notification.relatedUser.name) 回复了你的话题 \(notification.relatedTopic.title)"
        case .Favorite:
//            return "<b>\(notification.relatedUser.name)</b> 收藏了你的话题 <b>\(notification.relatedTopic.title)</b>"
            return "\(notification.relatedUser.name) 收藏了你的话题 \(notification.relatedTopic.title)"
        case .AppreciationForTopic:
//            return "<b>\(notification.relatedUser.name)</b> 感谢了你的话题 <b>\(notification.relatedTopic.title)</b>"
            return "\(notification.relatedUser.name) 感谢了你的话题 \(notification.relatedTopic.title)"
        case .AppreciationForReply:
//            return "<b>\(notification.relatedUser.name)</b> 感谢了你在话题 <b>\(notification.relatedTopic.title)</b> 中的回复"
            return "\(notification.relatedUser.name) 感谢了你在话题 \(notification.relatedTopic.title) 中的回复"
        case .AtInTopic:
//            return "<b>\(notification.relatedUser.name)</b> 在发表 <b>\(notification.relatedTopic.title)</b> 时提到了你"
            return "\(notification.relatedUser.name) 在发表 \(notification.relatedTopic.title) 时提到了你"
        case .AtInReply:
//            return "<b>\(notification.relatedUser.name)</b> 在回复 <b>\(notification.relatedTopic.title)</b> 时提到了你"
            return "\(notification.relatedUser.name) 在回复 \(notification.relatedTopic.title) 时提到了你"
        case .UnDefined:
            return "提醒类型未定义，请联系 App 作者"
//        default:
//            return "提醒类型未知，请联系 App 作者"
        }
    }
}