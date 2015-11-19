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
import LNNotificationsUI

class SessionService {
    
    class func checkLogin(forceCheck: Bool = false, responseClosure: ((result: NetworkingResult<Bool>) -> Void)?) {
                
        if SessionStorage.sharedStorage.shouldCheckLoginAsync || forceCheck {
            V2EXNetworking.get("").responseString { response in
                switch response.result {
                case .Success(let value):
                    let isLoggedIn = self.checkLoginFrom(HTMLStringOptional: value)
                    if isLoggedIn {
                        self.setBasicUserDataFrom(HTMLStringOptional: value)
                    }
                    responseClosure?(result: NetworkingResult<Bool>.Success(isLoggedIn))
                case .Failure(let error):
                    responseClosure?(result: NetworkingResult<Bool>.Failure(response.response, error))
                }
            }
        } else {
            responseClosure?(result: NetworkingResult<Bool>.Success(SessionStorage.sharedStorage.currentUser != nil))
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
    
    class func requestNewSessionFormOnceCode(response: ((result: NetworkingResult<String>) -> Void)?) {
        V2EXNetworking.get("signin").responseString { res in
            
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                let doc = TFHpple(HTMLStringOptional: value)
                let onceElement = doc.searchFirst("//div[@id='Main']//div[@class='box']//form//input[@name='once']")
                let code = (onceElement?["value"] as? String) ?? ""
                
                SessionStorage.sharedStorage.onceCode = code
                
                response?(result: NetworkingResult<String>.Success(code))
            }
        }
    }
    
    class func performLogin(username: String, password: String, response: ((result: NetworkingResult<Bool>) -> Void)?) {
        
        if SessionStorage.sharedStorage.shouldRequestNewOnceCode() {
            self.requestNewSessionFormOnceCode { (ret) in
            
                if ret.isFailure {
                    response?(result: NetworkingResult.Failure(nil, ret.error))
                    self.loginFailed()
                    return
                }
                
                self.postInfo(username, password: password, response: response)
            }
        } else {
            self.postInfo(username, password: password, response: response)
        }
    }
    
    private class func postInfo(username: String, password: String, response: ((result: NetworkingResult<Bool>) -> Void)?) {
        V2EXNetworking.post("signin", parameters: [
            "next": "/",
            "once": SessionStorage.sharedStorage.onceCode,
            "u": username,
            "p": password
            ], additionalHeaders: ["Referer": "http://www.v2ex.com/signin"]).responseString { res in
                
                switch res.result {
                case .Failure(let error):
                    V2EXAnalytics.event("Login Failure", description: error.description)
                    response?(result: NetworkingResult.Failure(res.response, error))
                case .Success(let value):
                    let isLoggedIn = self.checkLoginFrom(HTMLStringOptional: value)
                    if isLoggedIn {
                        self.setBasicUserDataFrom(HTMLStringOptional: value)
                        
                        // save
                        self.save(username: username, password: password)
                        //                    NSUserDefaults.standardUserDefaults().synchronize()
                        //                    let cookies = (NSHTTPCookieStorage.sharedHTTPCookieStorage().cookies ) ?? [NSHTTPCookie]()
                        
                        //                    for (_, cookie) in cookies.enumerate()
                        //                    {
                        //                        print(cookie)
                        //                    }
                        
                        V2EXAnalytics.event("Login Success")
                        response?(result: NetworkingResult<Bool>.Success(isLoggedIn))
                    } else {
                        self.loginFailed()
                        
                        // delete username and password saved
                        self.clearUsernameAndPassword()
                        
                        MemoryCache.setLoginFailureHTML(value)
                        
                        let doc = TFHpple(HTMLStringOptional: value)
                        if let _ = doc.searchFirst("//div[@class='box']//div[@class='problem']")?.text() {
                            let e = V2EXError.WrongUsernameOrPassword
                            V2EXAnalytics.event("Login Failure: Wrong username or password", description: e.description)
                            response?(result: NetworkingResult.Failure(res.response, e.foundationError))
                        } else if let errorMessage = doc.searchFirst("//div[@class='box']//div[@class='message']")?.text() {
                            var e = V2EXError.OtherProblem(errorMessage)
                            if errorMessage == "登录有点问题，请重试一次" {
                                e = V2EXError.LoginProblem
                            }
                            V2EXAnalytics.event("Login Failure", description: e.description)
                            response?(result: NetworkingResult.Failure(res.response, e.foundationError))
                        } else {
                            V2EXAnalytics.event("Login Failure", description: res.result.error?.description)
                            response?(result: NetworkingResult.Failure(res.response, res.result.error))
                        }
                    }
                }
                
                
                
                
        }
    }
    
    /**
    Check if login successful by find link of "创作新主题"
    
    :param: htmldata data from Alamofire
    
    :returns: Bool of result
    */
    private class func checkLoginFrom(HTMLStringOptional HTMLStringOptional: String?) -> Bool {

        let doc = TFHpple(HTMLStringOptional: HTMLStringOptional)
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
    
    private class func setBasicUserDataFrom(HTMLStringOptional HTMLStringOptional: String?) {
        let doc = TFHpple(HTMLStringOptional: HTMLStringOptional)
        // Get info of current user
        let infoElement = doc.searchFirst("//div[@id='Rightbar']//div[@class='box']//div[@class='cell']")
        let username = infoElement?.searchFirst("//span[@class='bigger']/a")?.text()
        let avatarURI = infoElement?.searchFirst("//img[@class='avatar']")?["src"] as? String
        // Save info to SessionStorage
        SessionStorage.sharedStorage.currentUser = User(name: username, avatarURI: avatarURI)
    }
    
    private class func save(username username: String, password: String) {
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
    
    class func getOnceCode(response: ((result: NetworkingResult<String>) -> Void)) {
        V2EXNetworking.get("new").responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                let doc = TFHpple(HTMLStringOptional: value)
                let onceElement = doc.searchFirst("//div[@id='Main']//div[@class='box']//form//input[@name='once']")
                let code = (onceElement?["value"] as? String) ?? ""
                
                SessionStorage.sharedStorage.onceCode = code
                
                response(result: NetworkingResult<String>.Success(code))
            }
        }
    }
    
    class func checkDailyRedeem(response: ((result: NetworkingResult<String?>) -> Void)?) {
        V2EXNetworking.get("mission/daily").responseString { res in
            switch res.result {
            case .Failure(let error):
                response?(result: NetworkingResult.Failure(res.response, error))
            case .Success(let value):
                let doc = TFHpple(HTMLStringOptional: value)
                if let buttonElement = doc.searchFirst("//input[@class='super normal button']"),
                    once = buttonElement.attr("onclick")?.match("once=(\\d+)")?[1] {
                        
                        SessionStorage.sharedStorage.onceCode = once
                        // TODO: Cache daily login for one day(do not send second request for signed task)
                        response?(result: NetworkingResult<String?>.Success(once))
                } else {
                    // TODO: More friendly error
                    response?(result: NetworkingResult<String?>.Success(nil))
                }
            }
        }
    }
    
    class func getDailyRedeem(response: (result: NetworkingResult<Bool>) -> Void) {
        
        V2EXAnalytics.event("Get Daily Redeem: Request")
        
        let onceCode = SessionStorage.sharedStorage.onceCode
        
        
        
        V2EXNetworking.get("mission/daily/redeem?once=\(onceCode)", additionalHeaders: ["Referer": "https://v2ex.com/mission/daily"]).responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Get Daily Redeem: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Get Daily Redeem: Success")
            }
        }
    }
    
    class func ignoreTopic(id: Int, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Ignore Topic: Request")
        let onceCode = SessionStorage.sharedStorage.onceCode
        
        V2EXNetworking.get("ignore/topic/\(id)?once=\(onceCode)").responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Ignore Topic: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Ignore Topic: Success")
            }
        }
    }
    
    class func reportTopic(reportLink: String, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Report Topic: Request")
        V2EXNetworking.get(reportLink).responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Report Topic: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Report Topic: Success")
            }
        }
    }
    
    class func favoriteTopic(favLink: String, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Favorite Topic: Request")
        V2EXNetworking.get(favLink).responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Favorite Topic: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Favorite Topic: Success")
            }
        }
    }
    
    class func appreciateTopic(id: Int, token: String, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Appreciate Topic: Request")
        V2EXNetworking.post("thank/topic/\(id)?t=\(token)").responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Appreciate Topic: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Appreciate Topic: Success")
            }
        }
    }
    
    class func appreciateReply(id: Int, token: String, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Appreciate Reply: Request")
        V2EXNetworking.post("thank/reply/\(id)?t=\(token)").responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Appreciate Reply: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Appreciate Reply: Success")
            }
        }
    }
    
    class func toggleFollowUser(id: Int, token: String, isFollowed: Bool, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Toggle Follow User: Request")
        let url: String = {
            if isFollowed {
                return "unfollow/\(id)?t=\(token)"
            } else {
                return "follow/\(id)?t=\(token)"
            }
        }()
        V2EXNetworking.get(url).responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Toggle Follow User: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Toggle Follow User: Success")
            }
        }
    }
    
    class func toggleBlockUser(id: Int, token: String, isBlocked: Bool, response:(result: NetworkingResult<Bool>) -> Void) {
        V2EXAnalytics.event("Toggle Block User: Request")
        let url: String = {
            if isBlocked {
                return "unblock/\(id)?t=\(token)"
            } else {
                return "block/\(id)?t=\(token)"
            }
            }()
        V2EXNetworking.get(url).responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Toggle Block User: Failure", description: error.description)
            case .Success(_):
                response(result: NetworkingResult<Bool>.Success(true))
                V2EXAnalytics.event("Toggle Block User: Success")
            }
        }
    }
    
    class func getNotificationCount(response: (result: NetworkingResult<(Int, Bool)>) -> Void) {
        V2EXAnalytics.event("Get Notification Count: Request")
        V2EXNetworking.get("").responseString { res in
            switch res.result {
            case .Failure(let error):
                response(result: NetworkingResult.Failure(res.response, error))
                V2EXAnalytics.event("Get Notification Count: Failure", description: error.description)
            case .Success(let value):
                let notificationCount = self.handleNotificationCount(value)
                let hasDailyRedeem = self.handleDailyRedeem(value)
                response(result: NetworkingResult<(Int, Bool)>.Success((notificationCount, hasDailyRedeem)))
                V2EXAnalytics.event("Get Notification Count: Success")
            }
        }
    }
    
    private class func handleDailyRedeem(HTMLStringOptional: String?) -> Bool {
        var hasDailyRedeem = false
        let doc = TFHpple(HTMLStringOptional: HTMLStringOptional)
//        let text = doc.searchFirst("//div[@id='Rightbar']")
        if let _ = doc.searchFirst("//div[@id='Rightbar']//a[@href='/mission/daily']") {
            hasDailyRedeem = true
        }
        return hasDailyRedeem
    }
    
    private class func handleNotificationCount(HTMLString: String?) -> Int {
        let doc = TFHpple(HTMLStringOptional: HTMLString)
        var count = 0
        if let notificationLink = doc.searchFirst("//div[@id='Rightbar']//a[@href='/notifications']"), text = notificationLink.text(), countText = text.match("(\\d+) 条未读提醒")?[1], c = Int(countText) {
            count = c
        }
        return count
    }
    
    class func showNotificationWhileCountIsNotZero(HTMLString: String?) {
        let count = handleNotificationCount(HTMLString)
        if count > 0 {
            let notification = LNNotification(message: "您有 \(count) 条未读提醒。")
            notification.defaultAction = LNNotificationAction(title: "阅读提醒", handler: { (action) -> Void in
                Utils.showOrReloadNotificationVC()
            })
            LNNotificationCenter.defaultCenter().presentNotification(notification, forApplicationIdentifier: "v2ex")
        }
    }
    
}
