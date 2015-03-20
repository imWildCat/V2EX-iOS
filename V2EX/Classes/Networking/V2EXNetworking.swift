//
//  V2EXNetworking.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Alamofire

private let BASE_URL = "https://v2ex.com/"

class V2EXNetworking: Networking {

    override class func get(URIString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return super.get(BASE_URL + URIString.URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
    
    override class func post(URIString: URLStringConvertible, parameters: [String : AnyObject]? = nil, encoding: Alamofire.ParameterEncoding = .URL, additionalHeaders: [String: String]? = nil) -> Request {
        return super.post(BASE_URL + URIString.URLString, parameters: parameters, encoding: encoding, additionalHeaders: additionalHeaders)
    }
}
