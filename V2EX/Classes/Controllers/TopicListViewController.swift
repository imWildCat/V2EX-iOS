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
        
        // set up right bar buttom
        if mode == .Node {
            let image = UIImage(named: "write_topic_icon")
            let button = UIBarButtonItem(image: image, style: .Plain, target: self, action: Selector("showCreateTopicVC"))
            self.navigationItem.rightBarButtonItem = button
        }
        
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        AVAnalytics.beginLogPageView("TopicListViewController")
        if topics.count == 0 {
            loadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        AVAnalytics.endLogPageView("TopicListViewController")
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
    
    
    @IBAction func refresh(sender: UIRefreshControl) {
        loadData()
    }
    
    func loadData() {
        page = 1
        
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        
        if let slug = tabSlug {
            TopicSerivce.getList(tabSlug: slug) { [weak self] (result) in
                if let topics = result.value {
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                } else {
                    self?.showError(result.error)
                }
                self?.hideProgressView()
            }
        } else if let slug = nodeSlug {
            navigationItem.title = "话题列表"
            TopicSerivce.getList(nodeSlug: slug) { [weak self] (result) in
                self?.hideProgressView()
                
                switch result {
                case .Success(let topics, let nodeName):
                    if let nodeName = nodeName {
                        self?.navigationItem.title = nodeName
                    }
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    self?.addLoadMoreDataFooter()
                case .Failure(_, let error):
                    self?.navigationItem.title = "请登录"
                    self?.showError(error)
                }
                
            }
        } else {
            // fav topic mode
            navigationItem.title = "我的收藏"
            TopicSerivce.favoriteTopics(1) { [weak self] (result) in
                self?.hideProgressView()
                
                if let (topics, count) = result.value {
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    
                    self?.addLoadMoreDataFooter()
                    if count <= 20 {
                        self?.tableView.footer.endRefreshingWithNoMoreData()
                    }
                } else {
                    self?.showError(result.error)
                }
            }
        }
    }
    
    func loadMoreData() {
        page++
        if let slug = nodeSlug where mode == .Node {
            TopicSerivce.getList(nodeSlug: slug, page: page) { [weak self] (result) in
                if let (topics, nodeName) = result.value {
                    if let name = nodeName {
                        self?.navigationItem.title = name
                    }
                    self?.topics += topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if topics.count < 20 {
                        self?.tableView.footer.endRefreshingWithNoMoreData()
                    }
                }
            }
        } else if mode == .Favorite {
            // my favorites
            TopicSerivce.favoriteTopics(page) { [weak self] (result) in
                if let (topics, _) = result.value {
                    self?.topics += topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if topics.count < 20 {
                        self?.tableView.footer.endRefreshingWithNoMoreData()
                    }
                }
            }
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
