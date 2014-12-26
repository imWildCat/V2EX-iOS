//
//  TopicViewController.swift
//  V2EX
//
//  Created by WildCat on 21/12/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class TopicViewController: UITableViewController {
    
    var topicId: Int = 0
    var topic = Topic(id: nil, title: nil, node: nil, author: nil)
    var replies = [Reply]()
    
    override func viewDidLoad() {
        
    }
    
    func load() {
        TopicSerivce.singleTopic(topicId, response: { [unowned self] (error, topic, replies) in
            if error == nil {
                self.topic = topic
                self.replies = replies
            }
        })
    }

}
