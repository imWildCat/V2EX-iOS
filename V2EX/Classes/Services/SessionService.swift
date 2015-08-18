//
//  SessionService.swift
//  V2EX
//
//  Created by WildCat on 20/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import hpple
import SimpleKeychain

class SessionService {
    
    class func checkLogin(response: ((error: NSError?, isLoggedIn: Bool) -> Void)?) {
        
        if SessionStorage.sharedStorage.currentUser == nil {
            response?(error: nil, isLoggedIn: false)
            return
        }
        
        V2EXNetworking.get("").response { (_, _, data, error) in
            let isLoggedIn = self.checkLoginFrom(htmldata: data)
            response?(error: error, isLoggedIn: isLoggedIn)
            if isLoggedIn {
                self.setBasicUserDataFrom(htmlData: data)
            }
            return
        }
    }
    
    class func logout() {
        Networking.clearCookies()
        
        let storage = SessionStorage.sharedStorage
        storage.currentUser = nil
        storage.onceCode = ""

//        let cookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
//        for cookie in cookieStorage.cookies as! [NSHTTPCookie] {
//            cookieStorage.deleteCookie(cookie)
//        }
        SessionService.clearUsernameAndPassword()
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func requestNewSessionFormOnceCode(response: ((error: NSError?, onceCode: String) -> Void)?) {
        V2EXNetworking.get("signin").response { (_, _, data, error) in
            
            let doc = TFHpple(HTMLObject: data)
            let onceElement = doc.searchFirst("//div[@id='Main']//div[@class='box']//form//input[@name='once']")
            let code = (onceElement?["value"] as? String) ?? ""
            
            SessionStorage.sharedStorage.onceCode = code
            
            response?(error: error, onceCode: code)
        }
    }
    
    class func performLogin(username: String, password: String, response: ((error: NSError?, isLoggedIn: Bool) -> Void)?) {
        
        if SessionStorage.sharedStorage.shouldRequestNewOnceCode() {
            self.requestNewSessionFormOnceCode { (error, _) in
                
                if error != nil {
                    response?(error: error, isLoggedIn: false)
                    self.loginFailed()
                    return
                }
                
                self.postInfo(username, password: password, response: response)
            }
        } else {
            self.postInfo(username, password: password, response: response)
        }
    }
    
    private class func postInfo(username: String, password: String, response: ((error: NSError?, isLoggedIn: Bool) -> Void)?) {
        V2EXNetworking.post("signin", parameters: [
            "next": "/",
            "once": SessionStorage.sharedStorage.onceCode,
            "u": username,
            "p": password
            ], additionalHeaders: ["Referer": "http://www.v2ex.com/signin"]).response { (_, _, data, error) in
                
                let isLoggedIn = self.checkLoginFrom(htmldata: data)
                
                if isLoggedIn {
                    self.setBasicUserDataFrom(htmlData: data)
                    
                    // save
                    self.save(username: username, password: password)
                    
                    response?(error: error, isLoggedIn: isLoggedIn)
                } else {
                    self.loginFailed()
                    
                    // delete username and password saved
                    self.clearUsernameAndPassword()
                    
                    response?(error: error, isLoggedIn: isLoggedIn)
                }
        }
    }
    
    /**
    Check if login successful by find link of "创作新主题"
    
    :param: htmldata data from Alamofire
    
    :returns: Bool of result
    */
    private class func checkLoginFrom(#htmldata: AnyObject?) -> Bool {

        let doc = TFHpple(HTMLObject: htmldata)
        let newTopicElement = doc.searchFirst("//div[@id='Rightbar']//div[@class='box']//a[@href='/new']")
        
        if newTopicElement != nil {
            return true
        } else {
            return false
        }
    }
    
    private class func loginFailed() {
        SessionStorage.sharedStorage.currentUser = nil
    }
    
    private class func setBasicUserDataFrom(#htmlData: AnyObject?) {
        let doc = TFHpple(HTMLObject: htmlData)
        // Get info of current user
        let infoElement = doc.searchFirst("//div[@id='Rightbar']//div[@class='box']//div[@class='cell']")
        let username = infoElement?.searchFirst("//span[@class='bigger']/a")?.text()
        let avatarURI = infoElement?.searchFirst("//img[@class='avatar']")?["src"] as? String
        // Save info to SessionStorage
        SessionStorage.sharedStorage.currentUser = User(name: username, avatarURI: avatarURI)
    }
    
    private class func save(#username: String, password: String) {
        let keychain = A0SimpleKeychain()
        keychain.setString(username, forKey:"v2ex-username")
        keychain.setString(password, forKey: "v2ex-password")
    }
    
    class func clearUsernameAndPassword() {
        let keychain = A0SimpleKeychain()
        keychain.deleteEntryForKey("v2ex-username")
        keychain.deleteEntryForKey("v2ex-password")
    }
    
    class func getUsernameAndPassword() -> (String?, String?) {
        let keychain = A0SimpleKeychain()
        return (keychain.stringForKey("v2ex-username"), keychain.stringForKey("v2ex-password"))
    }
    
    class func getOnceCode(response: ((error: NSError?, code: String) -> Void)) {
        V2EXNetworking.get("new").response { (_, _, data, error) in
            
            let doc = TFHpple(HTMLObject: data)
            let onceElement = doc.searchFirst("//div[@id='Main']//div[@class='box']//form//input[@name='once']")
            let code = (onceElement?["value"] as? String) ?? ""
            
            SessionStorage.sharedStorage.onceCode = code
            
            response(error: error, code: code)
        }
    }
    
    class func checkDailyRedeem(response: ((error: NSError?, onceCode: String?) -> Void)?) {
        V2EXNetworking.get("mission/daily").response { (_, _, data, error) in
            
            var onceCode: String?
            let doc = TFHpple(HTMLObject: data)
            if let buttonElement = doc.searchFirst("//input[@class='super normal button']"),
                once = buttonElement.attr("onclick")?.match("once=(\\d+)")?[1] {
                onceCode = once
                    
                SessionStorage.sharedStorage.onceCode = once
            }
            // TODO: Cache daily login for one day(do not send second request for signed task)
            response?(error: error, onceCode: onceCode)
        }
    }
    
    class func getDailyRedeem(response: (error: NSError?) -> Void) {
        
        let onceCode = SessionStorage.sharedStorage.onceCode
        
        V2EXNetworking.get("mission/daily/redeem?once=\(onceCode)").response { (_, _, data, error) in
            
           response(error: error)
        }
    }
    
    class func ignoreTopic(id: Int, response:(error: NSError?) -> Void) {
        
        let onceCode = SessionStorage.sharedStorage.onceCode
        
        V2EXNetworking.get("ignore/topic/\(id)?once=\(onceCode)").response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func reportTopic(reportLink: String, response:(error: NSError?) -> Void) {
        V2EXNetworking.get(reportLink).response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func favoriteTopic(favLink: String, response:(error: NSError?) -> Void) {
        V2EXNetworking.get(favLink).response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func appreciateTopic(id: Int, token: String, response:(error: NSError?) -> Void) {
        V2EXNetworking.post("thank/topic/\(id)?t=\(token)").response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func appreciateReply(id: Int, token: String, response:(error: NSError?) -> Void) {
        V2EXNetworking.post("thank/reply/\(id)?t=\(token)").response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func toggleFollowUser(id: Int, token: String, isFollowed: Bool, response:(error: NSError?) -> Void) {
        let url: String = {
            if isFollowed {
                return "unfollow/\(id)?t=\(token)"
            } else {
                return "follow/\(id)?t=\(token)"
            }
        }()
        V2EXNetworking.get(url).response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func toggleBlockUser(id: Int, token: String, isBlocked: Bool, response:(error: NSError?) -> Void) {
        let url: String = {
            if isBlocked {
                return "unblock/\(id)?t=\(token)"
            } else {
                return "block/\(id)?t=\(token)"
            }
            }()
        V2EXNetworking.get(url).response { (_, _, data, error) in
            response(error: error)
        }
    }
    
    class func getNotificationCount(response: (error: NSError?, count: Int) -> Void) {
        V2EXNetworking.get("").response { (_, _, data, error) in
            response(error: error, count: self.handleNotificationCount(data))
        }
    }
    
    class func handleNotificationCount(data: AnyObject?) -> Int {
        let doc = TFHpple(HTMLObject: data)
        var count = 0
        if let notificationLink = doc.searchFirst("//div[@id='Rightbar']//a[@href='/notifications']"), text = notificationLink.text(), countText = text.match("(\\d+) 条未读提醒")?[1], c = countText.toInt() {
            count = c
        }
        return count
    }
    
}
