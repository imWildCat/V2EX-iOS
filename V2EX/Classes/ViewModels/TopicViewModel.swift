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
            "avatar_url": "https:" + (topic.author?.avatarURI ?? ""),
            "username": topic.author?.name ?? "",
            "time": topic.createdAt,
            "device": "",
            "favorite_count": topic.favoriteCount.description,
            "appreciation_count": topic.appreciationCount.description,
            "content": topic.content
            ])
        
        for (_, reply) in enumerate(replies)
        {
            println("https:" + reply.author.avatarURI)
            posts.append([
                "avatar_url": "https:" + reply.author.avatarURI,
                "username": reply.author.name,
                "time": reply.time,
                "device": "",
                "favorite_count": "0",
                "appreciation_count": reply.appreciationsCount.description,
                "content": reply.content
                ])
        }
        
        var data = [
            "title": topic.title,
            "posts": posts
        ]
        
        var jsonObj = JSON(data)
        println(jsonObj.description)
        let bundle = NSBundle.mainBundle()
        let templatePath = bundle.pathForResource("topic", ofType: "html")
        let templateHTML =  String(contentsOfFile: templatePath ?? "", encoding: NSUTF8StringEncoding, error: nil) ?? ""
        
        let rendering = templateHTML.replace("{{data}}", withString: jsonObj.description)
//        println(rendering)
        return rendering
    }
}