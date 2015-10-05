//
//  UserService.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import hpple

class UserService {
    
    class func getUserInfo(username: String, response: ((result: NetworkingResult<User>) -> Void)? = nil) {
        V2EXNetworking.get("member/" + username).responseString { (_, res, ret) in
            
            if ret.isFailure {
                response?(result: NetworkingResult.Failure(res, ret.error))
                return
            }
            
            let doc = TFHpple(HTMLStringOptional: ret.value)
            
            let info = doc.searchFirst("//div[@id='Main']//div[@class='box']/div[@class='cell']")
            
            let name = info?.searchFirst("//h1")?.text()
            
            let idAndCreatedAt = info?.searchFirst("//span[@class='gray']")?.text()
            let id = idAndCreatedAt?.match("V2EX 第 (\\d+) 号会员")?[1]
            let createdAt = idAndCreatedAt?.match("加入于 ((\\d{4})-(\\d{2})-(\\d{2})) ")?[1]
            
            let avatarURI = info?.searchFirst("//img[@class='avatar']")?["src"] as? String
            
            let companyRaw = info?.searchFirst("//span[2]")?.raw
            let companyName = companyRaw?.match("<strong>(.+)</strong>")?[1] ?? ""
            let companyPosition = companyRaw?.match("</strong> /  (.+)</span>")?[1] ?? ""
            let company = companyName + " " + companyPosition
            
            let liveness = info?.searchFirst("//span[@class='gray']/a[@href='/top/dau']")?.text()
            let introduction = (doc.searchFirst("//div[@id='Main']//div[@class='box'][1]/div[@class='cell'][2]")?.content ?? "").replace("        ", withString: "")

            var user = User(name: name, avatarURI: avatarURI, website: nil, twitter: nil, github: nil, createdAt: createdAt, liveness: liveness, id: id, company: company, introduction: introduction)
            
            func parseActionToken(from: String?) -> String? {
                return from?.match("/\\d+\\?t=(\\d+)")?[1]
            }
            
            if let followElement = doc.searchFirst("//input[@value='加入特别关注']") {
                user.actionToken = parseActionToken(followElement.attr("onclick"))
            } else if let unFollowElement = doc.searchFirst("//input[@value='取消特别关注']") {
                user.actionToken = parseActionToken(unFollowElement.attr("onclick"))
                user.isFollowed = true
            }
            
//            if let blockElement = doc.searchFirst("//input[@value='Block']") {
//                
//            } else
            if let _ = doc.searchFirst("//input[@value='Unblock']") {
                user.isBlocked = true
            }
            
            if user.name == SessionStorage.sharedStorage.currentUser?.name {
               SessionStorage.sharedStorage.currentUser = user
            }
            
            response?(result: NetworkingResult<(User)>.Success(user))
        }
    }
}