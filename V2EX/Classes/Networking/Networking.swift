//
//  Networking.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation
import Alamofire

private let sharedManagerInstance = Networking.initManager()

class Networking {
    
    class func initManager() -> Manager {
        let cookies = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cfg = NSURLSessionConfiguration.defaultSessionConfiguration()
        
        cfg.HTTPCookieStorage = cookies
        cfg.HTTPAdditionalHeaders = [
          "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_5) AppleWebKit/600.8.9 (KHTML, like Gecko) Version/8.0.8 Safari/600.8.9"
        ]
        
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let c = (storage.cookies ) ?? [NSHTTPCookie]()
        
        for (_, cookie) in c.enumerate()
        {
            print(cookie)
        }
        
        return Alamofire.Manager(configuration: cfg)
    }
    
    class func sharedManager() -> Manager {
        return sharedManagerInstance
    }
    
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = (storage.cookies) ?? [NSHTTPCookie]()
        
        for (_, cookie) in cookies.enumerate()
        {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func request(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
//        if let headers = additionalHeaders, oldHeader = sharedManager().session.configuration.HTTPAdditionalHeaders as? [String: String] {
//            var newHeaders = headers
//            newHeaders.merge(oldHeader)
//            sharedManager().session.configuration.HTTPAdditionalHeaders = newHeaders
//        }
        return sharedManager().request(method, URLString, parameters: parameters, encoding: encoding, headers: additionalHeaders)
    }
    
    class func get(URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return request(.GET, URLString: URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
    
    
    class func post(URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return request(.POST, URLString: URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
    
  
    
}