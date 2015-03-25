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
    var nodeSlug: String?
    var topics = [Topic]()
    
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if topics.count == 0 {
            loadData()
        }
    }
    
    @IBAction func refresh(sender: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        if refreshControl?.refreshing == false {
            showProgressView()
        }
    
        
        if let slug = tabSlug {
            TopicSerivce.getList(tabSlug: slug, response: { [unowned self] (error, topics) in
                if error == nil {
                    self.topics = topics
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                self.hideProgressView()
            })
        } else if let slug = nodeSlug {
            navigationItem.title = "话题列表"
            TopicSerivce.getList(nodeSlug: slug, response: { [unowned self] (error, topics, nodeName) in
                if error == nil {
                    if let name = nodeName {
                        self.navigationItem.title = name
                    }
                    self.topics = topics
                    self.tableView.reloadData()
                    self.refreshControl?.endRefreshing()
                }
                self.hideProgressView()
            })
        } else {
            fatalError("tabSlug is nil.")
        }
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
            parentVC.performSegueWithIdentifier("showTopicVC", sender: topics[indexPath.row])
        } else if nodeSlug != nil {
            performSegueWithIdentifier("showTopicVC", sender: topics[indexPath.row])
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let topic = sender as Topic
            let destinationViewController = segue.destinationViewController as TopicViewController
            destinationViewController.topicId = topic.id
        }
    }

}
