//
//  TopicListViewController.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit

class TopicListViewController: UITableViewController {
    
    var tabSlug: String?
    var topics = [Topic]()
    
    override func viewDidAppear(animated: Bool) {
        println("appear")
        
       
    }
    
  
    override func viewDidDisappear(animated: Bool) {
        println("disappear")
    }
    
    override func viewDidLoad() {
        println("load")
        
        TopicSerivce.getList(tabSlug!, response: { [unowned self] (error, topics) in
            if error == nil {
                self.topics = topics
                self.tableView.reloadData()
            }
        })
        
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicListCell", forIndexPath: indexPath) as TopicListCell
        let cellViewModel = TopicListCellViewModel(topic: topics[indexPath.row])
        
        cell.render(cellViewModel)
        
        return cell
    }

}
