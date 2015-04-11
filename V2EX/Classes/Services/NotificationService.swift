//
//  NotificationService.swift
//  V2EX
//
//  Created by WildCat on 04/04/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import Foundation
import hpple

class NotificationService {
    
    class func get(page: Int = 1, response: ((error: NSError?, notifications: [Notification]) -> Void)? = nil) {
        V2EXNetworking.get("notifications", parameters: ["p": page]).response {
            (_, _, data, error) in
            let doc = TFHpple(HTMLObject: data)
            
            let rows = doc.searchElements("//div[@id='Main']//div[@class='box']//div[@class='cell']/table[1]//tr")
            for row in rows {
                let imageURI = row.searchFirst("//td[1]//img/@src")?.content
                let username = row.searchFirst("//td[2]/span[@class='fade']/a[1]/strong")?.content
                println(1)
            }
            println(rows.count)
        }
    }
}