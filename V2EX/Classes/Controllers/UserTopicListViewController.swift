//
//  UserTopicListViewController
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit
import MJRefresh

class UserTopicListViewController: UITableViewController {
    
    var username: String!
    var topics = [Topic]()
    var currentPage = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 103
        
        loadData(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("UserTopicListViewController")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("UserTopicListViewController")
    }
    
    @IBAction func refreshControlValueDidChange(sender: UIRefreshControl) {
        loadData()
    }

    func loadData(shouldShowProgressView: Bool = false) {
        if shouldShowProgressView {
            showProgressView()
        }
        
        TopicSerivce.topicListOfUser(username, page: currentPage) { [weak self] (result) in
            self?.hideProgressView()
            self?.refreshControl?.endRefreshing()
            
            if let topicListPage = result.value {
                self?.topics = topicListPage.topics
                self?.tableView.reloadData()
                
                if topicListPage.currentPage < topicListPage.totalPage {
                    self?.addLoadMoreDataFooter()
                }
            } else {
                self?.showError()
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
        currentPage += 1
        TopicSerivce.topicListOfUser(username, page: currentPage) { [weak self] (result) in
            if let topicListPage = result.value {
                self?.topics += topicListPage.topics
                self?.tableView.reloadData()
                
                self?.addLoadMoreDataFooter()
                if topicListPage.currentPage == topicListPage.totalPage {
                    self?.tableView.footer.endRefreshingWithNoMoreData()
                }
            } else {
                self?.showError()
            }
        }
    }

    // MARK: UITableViewDataSorce
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! UserTopicTableViewCell
        
        cell.render(UserTopicListCellViewModel(topic: topics[indexPath.row]))
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    // MARK: UITableViewDelegate
//    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let topic = topics[indexPath.row]
//        
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "showTopicVC" {
                let destinationViewController = segue.destinationViewController as! TopicViewController
                
                if let index = tableView.indexPathForSelectedRow?.row {
                    let topic = topics[index]
                    destinationViewController.topicID = topic.id
                }
            }
        }
    }

}
