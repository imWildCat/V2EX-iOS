//
//  UserReplyListController.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import MJRefresh

class UserReplyListController: UITableViewController {
    
    var username: String!
    var replies = [Reply]()
    var page = 1
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .None
        
        tableView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        
        loadData(shouldShowProgressView: true)
    }
    
    func loadData(shouldShowProgressView: Bool = false) {
        if shouldShowProgressView {
            showProgressView()
        }
        
        TopicSerivce.replyListOf(user: username, page: page) { [weak self] (error, replies, hasMorePage) in
            self?.hideProgressView()
            if error == nil {
                self?.replies = replies
                self?.tableView.reloadData()
                
                if hasMorePage {
                     self?.addLoadMoreDataFooter()
                }
                
                self?.refreshControl?.endRefreshing()
                
            } else {
                self?.showError(.Networking)
            }
        }
    }
    
    // MARK: Load more data
    
    func addLoadMoreDataFooter() {
        tableView.footer = MJRefreshAutoNormalFooter(refreshingBlock: { [unowned self] in
            self.loadMoreData()
        })
    }
    
    func loadMoreData() {
        page++
        
        TopicSerivce.replyListOf(user: username, page: page) { [weak self] (error, replies, hasNextPage) in
            self?.hideProgressView()
            if error == nil {
                self?.replies += replies
                self?.tableView.reloadData()
                
                self?.addLoadMoreDataFooter()
                
                if !hasNextPage {
                    self?.tableView.footer.noticeNoMoreData()
                }
                
            } else {
                self?.showError(.Networking)
            }
        }
    }
    
    @IBAction func refreshControlValueDidChange(sender: UIRefreshControl) {
        loadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "showTopicVC" {
                let destinationViewController = segue.destinationViewController as! TopicViewController
                
                if let index = tableView.indexPathForSelectedRow()?.row {
                    let reply = replies[index]
                    destinationViewController.topicID = reply.relatedTopic?.id ?? 0
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
