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
    class func getList(nodeSlug: String, response: ((error: NSError?, topics: [Topic]?) -> Void)?) {

        V2EXNetworking.get("", parameters: ["tab": nodeSlug]).response { (_, _, data, error) in
            
            var topics: [Topic]?
            
            if error == nil {
                let doc = TFHpple(HTMLData: data as NSData)
                
                let elements = doc.searchWithXPathQuery("//div[@id='Main']//div[@class='box']/div[@class='cell item']/table") as [TFHppleElement]
                
                for element in elements {
                    let titleElement = element.searchFirst("//td[3]/span[@class='item_title']/a")
                    let topicTitle = titleElement?.text() ?? ""
                    
                }
                
            } else {
                println("EEROR")
            }
            
            response?(error: error, topics: topics)
        }
    }
}
