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
    
    override func viewDidLoad() {
        

    }
    
    override func viewDidAppear(animated: Bool) {
        if topics.count == 0 {
            loadData()
        }
        println("appear")
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        
        TopicSerivce.getList(tabSlug!, response: { [unowned self] (error, topics) in
            if error == nil {
                self.topics = topics
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            self.hideProgressView()
        })
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicListCell", forIndexPath: indexPath) as TopicListCell
        let cellViewModel = TopicListCellViewModel(topic: topics[indexPath.row])
        
        cell.render(cellViewModel)
        
        return cell
    }

    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tabSlug != nil {
            let parentVC = ContainerViewController.sharedDiscoveryVC()!
            parentVC.performSegueWithIdentifier("showTopicVC", sender: topics[indexPath.row] as AnyObject)
        }
    }

}
