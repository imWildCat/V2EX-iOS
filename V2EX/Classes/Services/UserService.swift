//
//  UserService.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

class UserService {
    
    class func getUserInfo(username: String, response: ((error: NSError?, user: User, topicsRelated: [Topic], repliesRelated: [Reply]) -> Void)? = nil) {
        V2EXNetworking.get("member/" + username).response { (_, _, data, error) in
            let doc = TFHpple(HTMLObject: data)
            
            let info = doc.searchFirst("//div[@id='Main']//div[@class='box']/div[@class='cell']")
            
            let name = info?.searchFirst("//h1")?.text()
            
            let idAndCreatedAt = info?.searchFirst("//span[@class='gray']")?.text()
            let id = idAndCreatedAt?.match("V2EX 第 (\\d+) 号会员")?[1]
            let createdAt = idAndCreatedAt?.match("加入于 ((\\d{4})-(\\d{2})-(\\d{2})) ")?[1]
            
            let avatarURI = info?.searchFirst("//img[@class='avatar']")?["src"] as String?
            
            let companyRaw = info?.searchFirst("//span[2]")?.raw
            let companyName = companyRaw?.match("<strong>(.+)</strong>")?[1] ?? ""
            let companyPosition = companyRaw?.match("</strong> /  (.+)</span>")?[1] ?? ""
            let company = companyName + " " + companyPosition
            
            let liveness = info?.searchFirst("//span[@class='gray']/a[@href='/top/dau']")?.text()
            
            let user = User(name: name, avatarURI: avatarURI, website: nil, twitter: nil, github: nil, createdAt: createdAt, liveness: liveness, id: id, company: company, introduction: nil)
            
            if user.name == SessionStorage.sharedStorage.currentUser?.name {
               SessionStorage.sharedStorage.currentUser = user
            }
            
            response?(error: error, user: user, topicsRelated: [Topic](), repliesRelated: [Reply]())
        }
    }
}