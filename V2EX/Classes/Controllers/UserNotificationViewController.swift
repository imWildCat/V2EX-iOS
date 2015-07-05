//
//  UserNotificationViewController.swift
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
//import SVPullToRefresh
import MJRefresh

class UserNotificationViewController: V2EXTableViewController {
    
    var page: Int = 1
    var notifications = [Notification]()
    var cellViewModels = [UserNotificationListCellViewModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
//        tableView.separatorStyle = .None
        
        loadData()
    }
    
    func addLoadMoreDataFooter() {
        tableView.addLegendFooterWithRefreshingBlock { [weak self] () -> Void in
            self?.loadMoreData()
        }
//        if notifications.count < 10 {
//            tableView.footer.noticeNoMoreData()
//        }
    }
    
    
    
    @IBAction func refreshControlDidChanged(sender: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        page = 1
        if refreshControl?.refreshing == false {
            showProgressView()
            addLoadMoreDataFooter()
        }
        NotificationService.get(page: page) { [weak self] (error, notifications) in
            if error != nil {
                self?.showError(.Networking)
            } else {
                self?.notifications += notifications
                self?.generateCellViewModels()
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.hideProgressView()
                self?.tableView.footer.stateHidden = true
                self?.addLoadMoreDataFooter()
            }
        }
    }
    
    func loadMoreData() {
        page += 1

        NotificationService.get(page: page) { [weak self] (error, notifications) in
            if error != nil {
                self?.showError(.Networking)
            } else {
                self?.notifications += notifications
                self?.generateCellViewModels()
                self?.tableView.reloadData()
                self?.addLoadMoreDataFooter()
                if notifications.count < 10 {
                    self?.tableView.footer.noticeNoMoreData()
                }
            }
        }

    }
    
    func generateCellViewModels() {
        cellViewModels = [UserNotificationListCellViewModel]()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        if let topicViewController = storyboard?.instantiateViewControllerWithIdentifier("topicVC") as? TopicViewController {
//            let notification = notifications[indexPath.row]
//            topicViewController.topicId = notification.relatedTopic.id
//            presentViewController(topicViewController, animated: true, completion: nil)
//        }
        
//        println(indexPath.row)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let destinationViewController = segue.destinationViewController as! TopicViewController
            
            if let index = tableView.indexPathForSelectedRow()?.row {
                println(index)
                let notification = notifications[index]
                destinationViewController.topicId = notification.relatedTopic.id
            }
        }
    }

}
