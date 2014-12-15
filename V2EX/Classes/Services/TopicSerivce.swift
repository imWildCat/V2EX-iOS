//
//  TopicSerivce.swift
//  V2EX
//
//  Created by WildCat on 14/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import Foundation

//enum TabSlug: String {
//    case ALL = "all"
//    case HOT = "hot"
//    case R2  = "r2"
//    case QNA = "qna"
//    case CITY = "city"
//    case DEALS = "deals"
//    case JOBS = "jobs"
//    case APPLE = "apple"
//    case PLAY = "play"
//}

class TopicSerivce {
    class func getList(tabSlug: String, response: ((error: NSError?, topics: [Topic]) -> Void)?) {

        V2EXNetworking.get("", parameters: ["tab": tabSlug]).response { (_, _, data, error) in
            
            let topics = Topic.listFromTab(data)
            
            response?(error: error, topics: topics)
        }
    }
}
