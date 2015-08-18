//
//  TopicListViewController.swift
//  V2EX
//
//  Created by WildCat on 17/11/2014.
//  Copyright (c) 2014 WildCat. All rights reserved.
//

import UIKit
import MJRefresh

class TopicListViewController: UITableViewController {
    
    enum Mode {
        case Tab
        case Node
        case Favorite
    }
    
    var mode: Mode = .Favorite
    
    var tabSlug: String? {
        didSet {
            mode = .Tab
        }
    }
    var nodeSlug: String? {
        didSet {
            mode = .Node
        }
    }
    var topics = [Topic]()
    var prevousPage = 1
    var page = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set bg color
        tableView.backgroundColor = UIColor(red: 253/255, green: 248/255, blue: 234/255, alpha: 1)
        // set up right bar buttom
        if mode == .Node {
            let image = UIImage(named: "write_topic_icon")
            let button = UIBarButtonItem(image: image, style: .Plain, target: self, action: Selector("showCreateTopicVC"))
            self.navigationItem.rightBarButtonItem = button
        }
    }
    
    func addLoadMoreDataFooter() {
        if mode != .Tab {
            tableView.footer = MJRefreshAutoNormalFooter(refreshingBlock: { [unowned self] in
                self.loadMoreData()
            })
        }
    }
    
    func showCreateTopicVC() {
        if !isLoggedIn {
            return
        }
        
        if let slug = nodeSlug, createTopicVC = storyboard?.instantiateViewControllerWithIdentifier("createTopicVC") as? CreateTopicViewController {
            createTopicVC.nodeSlug = slug
            createTopicVC.topicListVC = self
            presentViewController(createTopicVC, animated: true, completion: nil)
        } else {
            showError(status: "节点未定义，无法创建话题")
        }
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
        page = 1
        
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        
        if let slug = tabSlug {
            TopicSerivce.getList(tabSlug: slug, response: { [weak self] (error, topics) in
                if error == nil {
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                }
                self?.hideProgressView()
            })
        } else if let slug = nodeSlug {
            navigationItem.title = "话题列表"
            TopicSerivce.getList(nodeSlug: slug, response: { [weak self] (error, topics, nodeName) in
                self?.hideProgressView()
                
                if error == nil {
                    if let name = nodeName {
                        self?.navigationItem.title = name
                    }
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    self?.addLoadMoreDataFooter()
                } else {
                    self?.navigationItem.title = "请登录"
                    self?.showError(error)
                }
            })
        } else {
            // fav topic mode
            navigationItem.title = "我的收藏"
            TopicSerivce.favoriteTopics(page: 1, response: { [weak self] (error, topics, totalCount) in
                if error == nil {
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    
                    self?.addLoadMoreDataFooter()
                    if totalCount <= 20 {
                        self?.tableView.footer.noticeNoMoreData()
                    }
                }
                self?.hideProgressView()
            })
        }
    }
    
    func loadMoreData() {
        page++
        if let slug = nodeSlug where mode == .Node {
            TopicSerivce.getList(nodeSlug: slug, page: page, response: { [weak self] (error, topics, nodeName) in
                if error == nil {
                    if let name = nodeName {
                        self?.navigationItem.title = name
                    }
                    self?.topics += topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if topics.count < 20 {
                        self?.tableView.footer.noticeNoMoreData()
                    }
                }
            })
        } else if mode == .Favorite {
            // my favorites
            TopicSerivce.favoriteTopics(page: page, response: { [weak self] (error, topics, totalCount) in
                if error == nil {
                    self?.topics += topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if topics.count < 20 {
                        self?.tableView.footer.noticeNoMoreData()
                    }
                }
            })
        }
    }
    
    // MARK: UITableViewDataSource
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicListCell", forIndexPath: indexPath) as! TopicListCell
        let cellViewModel = TopicListCellViewModel(topic: topics[indexPath.row])
        
        cell.render(cellViewModel)
        
        return cell
    }

    // MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if tabSlug != nil {
            let parentVC = ContainerViewController.sharedDiscoveryVC()!
            parentVC.performSegueWithIdentifier("showTopicVC", sender: topics[indexPath.row])
        } else /* if nodeSlug != nil */ {
//            performSegueWithIdentifier("showTopicVC", sender: topics[indexPath.row])
            showTopic(topics[indexPath.row])
        }
    }
    
    func showTopic(topic: Topic) {
        performSegueWithIdentifier("showTopicVC", sender: topic)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showTopicVC" {
            let topic = sender as? Topic
            let destinationViewController = segue.destinationViewController as! TopicViewController
            if let topic = sender as? Topic {
                if topic.isNew == false {
                    destinationViewController.topicID = topic.id
                } else {
                    destinationViewController.mode = .NewTopic
                    destinationViewController.topic = topic
                }
            }
        }
    }

}
