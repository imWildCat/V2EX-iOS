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
                
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.tableFooterView = UIView()
//        tableView.separatorStyle = .None
        
        loadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    func addLoadMoreDataFooter() {
        tableView.footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: "loadMoreData")
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
        NotificationService.get(page) { [weak self] (result) in
            self?.hideProgressView()
            switch result {
            case .Success(let notificationPage):
                self?.notifications += notificationPage.notifications
                self?.generateCellViewModels()
                self?.tableView.reloadData()
                self?.refreshControl?.endRefreshing()
                self?.hideProgressView()
                self?.tableView.footer.hidden = true
                if notificationPage.isLastPage {
                    self?.tableView.footer.hidden = true
                } else {
                    self?.addLoadMoreDataFooter()
                }
            case .Failure(_, let error):
                 self?.showError(error)
            }
        }
    }
    
    func loadMoreData() {
        page += 1

        NotificationService.get(page) { [weak self] (result) in
            
            switch result {
            case .Success(let notificationPage):
                self?.notifications += notificationPage.notifications
                self?.generateCellViewModels()
                self?.tableView.reloadData()
                self?.addLoadMoreDataFooter()
                if notificationPage.isLastPage {
                    self?.tableView.footer.endRefreshingWithNoMoreData()
                }
            case .Failure(_, let error):
                self?.showError(error)
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
            
            if let index = tableView.indexPathForSelectedRow?.row {
                let notification = notifications[index]
                destinationViewController.topicID = notification.relatedTopic.id
            }
        }
    }

}
