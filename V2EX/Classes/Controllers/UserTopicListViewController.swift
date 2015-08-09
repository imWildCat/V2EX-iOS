//
//  UserTopicListViewController
//  V2EX
//
//  Created by WildCat on 21/03/2015.
//  Copyright (c) 2015 WildCat. All rights reserved.
//

import UIKit

class UserTopicListViewController: UITableViewController {
    
    var username: String!
    var topics = [Topic]()
    var page: UInt = 1
    
    override func viewDidLoad() {
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 103
        
        loadData()
    }
    
    @IBAction func refreshControlValueDidChange(sender: UIRefreshControl) {
        
        loadData()
    }

    func loadData() {
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        
        TopicSerivce.topicListOf(user: username, page: page) { [weak self](error, topics) in
            
            self?.hideProgressView()
            self?.refreshControl?.endRefreshing()
            
            if error == nil {
                self?.topics = topics
                self?.tableView.reloadData()
            } else {
                self?.showError(.Networking)
            }
            
            return
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
                
                if let index = tableView.indexPathForSelectedRow()?.row {
                    let topic = topics[index]
                    destinationViewController.topicID = topic.id
                }
            }
        }
    }

}
