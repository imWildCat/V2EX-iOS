//
//  UserNotificationViewController.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import SVPullToRefresh

class UserNotificationViewController: V2EXTableViewController {
    
    var page: Int = 1
    var notifications = [Notification]()
    var cellViewModels = [UserNotificationListCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        tableView.rowHeight = UITableViewAutomaticDimension
//        tableView.estimatedRowHeight = 100
        
//        setUpBottomRefreshControl { [weak self] in
//            self?.loadData()
//        }
        
        
        loadData()
        
        tableView.addPullToRefreshWithActionHandler({ [unowned self] in
            println("test")
        }, position: SVPullToRefreshPosition.Bottom)


    }
    
    
    
    @IBAction func refreshControlDidChanged(sender: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        NotificationService.get(page: page) { [weak self](error, notifications) in
            if error != nil {
                self?.showError(.Networking)
            } else {
                self?.notifications = notifications
                self?.generateCellViewModels()
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.hideProgressView()
            }
        }
    }
    
    func generateCellViewModels() {
        for notification in notifications {
            let cellViewModel = UserNotificationListCellViewModel(notification: notification)
            cellViewModels.append(cellViewModel)
        }
    }
    
    // MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserNotificationListCell
        
        cell.render(cellViewModels[indexPath.row])
        
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let destinationViewController = segue.destinationViewController as! TopicViewController
            
            if let index = tableView.indexPathForSelectedRow()?.row {
                let notification = notifications[index]
                destinationViewController.topicId = notification.relatedTopic.id
            }
        }
    }

}
