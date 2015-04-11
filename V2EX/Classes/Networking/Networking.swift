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
        
        return Alamofire.Manager(configuration: cfg)
    }
    
    class func sharedManager() -> Manager {
        return sharedManagerInstance
    }
    
    class func clearCookies() {
        let storage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        let cookies = (storage.cookies as! [NSHTTPCookie]?) ?? [NSHTTPCookie]()
        
        for (_, cookie) in enumerate(cookies)
        {
            storage.deleteCookie(cookie)
        }
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    class func request(method: Alamofire.Method, URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        if let headers = additionalHeaders {
            sharedManager().session.configuration.HTTPAdditionalHeaders = headers
        }
        return sharedManager().request(method, URLString, parameters: parameters, encoding: encoding)
    }
    
    class func get(URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return request(.GET, URLString: URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
    
    
    class func post(URLString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return request(.POST, URLString: URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
    
  
    
}