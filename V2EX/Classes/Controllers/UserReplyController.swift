//
//  UserReplyListController.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserReplyListController: UITableViewController {
    
    var replies = [Reply]()
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .None
        
        loadData()
    }
    
    func loadData() {
        showProgressView()
        TopicSerivce.replyListOf(user: "wildcat", page: 1) { [weak self](error, replies) -> Void in
            self?.hideProgressView()
            if error == nil {
                self?.replies = replies
                self?.tableView.reloadData()
            } else {
                self?.showError(.Networking)
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "showTopicVC" {
                let destinationViewController = segue.destinationViewController as! TopicViewController
                
                if let index = tableView.indexPathForSelectedRow()?.row {
                    let reply = replies[index]
                    destinationViewController.topicId = reply.relatedTopic?.id ?? 0
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserReplyListTableViewCell
        
        let viewModel = UserReplyListCellViewModel(reply: replies[indexPath.row])
        cell.render(viewModel)
        
        return cell
    }

}
