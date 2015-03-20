//
//  SessionService.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation

class SessionService {
    
    class func newSessionForm(response: ((error: NSError?, onceCode: String) -> Void)?) {
        V2EXNetworking.get("signin").response { (_, _, data, error) in
            
            let doc = TFHpple(HTMLObject: data)
            let onceElement = doc.searchFirst("//div[@id='Main']//div[@class='box']//form//input[@name='once']")
            let code = (onceElement?["value"] as String?) ?? ""
            
            SessionStorage.sharedStorage.onceCode = code
            
            response?(error: error, onceCode: code)
        }
    }
    
    class func performLogin(username: String, password: String, response: ((error: NSError?, isLoggedIn: Bool) -> Void)?) {
        
        
        if (NSDate.currentTimestamp() - SessionStorage.sharedStorage.lastOnceGot) > 300 {
            SessionService.newSessionForm { (_, _) in
                SessionService.postInfo(username, password: password, response: response)
            }
        } else {
            SessionService.postInfo(username, password: password, response: response)
        }
    }
    
    private class func postInfo(username: String, password: String, response: ((error: NSError?, isLoggedIn: Bool) -> Void)?) {
        V2EXNetworking.post("signin", parameters: [
            "next": "/",
            "once": SessionStorage.sharedStorage.onceCode,
            "u": username,
            "p": password
            ], additionalHeaders: ["Referer": "http://www.v2ex.com/signin"]).response { (_, _, data, error) in
                
                let doc = TFHpple(HTMLObject: data)
                let avatarElement = doc.searchFirst("//div[@id='Rightbar']//div[@class='box']//a[@href='/new']")
                let html = doc.searchFirst("//body")?.text()
                println(avatarElement)
                
                if (error != nil) || (avatarElement == nil) {
                    response?(error: error, isLoggedIn: false)
                } else {
                    response?(error: error, isLoggedIn: true)
                }
        }
    }
}
