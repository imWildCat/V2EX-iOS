//
//  TopicViewModel.swift
//  V2EX
//
//  Created by WildCat on 16/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TopicViewModel {
    static func renderHTML(topic: Topic, replies: [Reply]) -> String {
        var posts = [[String: String]]()
        posts.append([
            "id": "0",
            "avatar_url": "https:" + (topic.author?.avatarURI ?? ""),
            "username": topic.author?.name ?? "",
            "time": topic.createdAt,
            "device": "",
            "favorite_count": topic.favoriteCount.description,
            "appreciation_count": topic.appreciationCount.description,
            "is_appreciated": topic.isAppreciated.description,
            "content": topic.content + topic.postscript
            ])
        
        for (_, reply) in replies.enumerate()
        {
            posts.append([
                "id": reply.id.description,
                "avatar_url": "https:" + reply.author.avatarURI,
                "username": reply.author.name,
                "time": reply.time,
                "device": "",
                "favorite_count": "0",
                "appreciation_count": reply.appreciationsCount.description,
                "is_appreciated": reply.isAppreciated.description,
                "content": reply.content,
                "floor": String(reply.floor)
                ])
        }
        
        let data = [
            "title": topic.title,
            "posts": posts,
            "nodeName": (topic.node?.name) ?? ""
        ]
        
        let jsonObj = JSON(data)
        
        let bundle = NSBundle.mainBundle()
        let templatePath = bundle.pathForResource("topic", ofType: "html")
        let templateHTML =  (try? String(contentsOfFile: templatePath ?? "", encoding: NSUTF8StringEncoding)) ?? ""
        
        let rendering = templateHTML.replace("{{fontSize}}", withString: UIViewController.topicFontSizeSetting.cssClassName).replace("{{data}}", withString: jsonObj.description)
        return rendering
    }
}