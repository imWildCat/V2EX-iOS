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
        
        if mode == .Tab {
            let screenSize = UIScreen.mainScreen().bounds
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: 35))
            label.textAlignment = .Center
            label.font = .systemFontOfSize(12.0)
            label.textColor = .grayColor()
            label.text = "没有更多页了"
            tableView.tableFooterView = label
        } else {
            tableView.tableFooterView = UIView()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if topics.count == 0 {
            loadData()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    func loadData(completion: (() -> ())? = nil) {
        page = 1
        
        if refreshControl?.refreshing == false {
            showProgressView()
        }
        
        if let slug = tabSlug {
            TopicSerivce.getList(tabSlug: slug) { [weak self] (result) in
                defer {
                    self?.hideProgressView()
                    completion?()
                }
                if let topics = result.value {
                    self?.topics = topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                } else {
                    self?.showError(result.error)
                }
            }
        } else if let slug = nodeSlug {
            navigationItem.title = "话题列表"
            TopicSerivce.getList(nodeSlug: slug) { [weak self] (result) in
                defer {
                    self?.hideProgressView()
                    completion?()
                }
                switch result {
                case .Success(let nodePage):
                    if let nodeName = nodePage.nodeName {
                        self?.navigationItem.title = nodeName
                    }
                    self?.topics = nodePage.topics
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
                defer {
                    self?.hideProgressView()
                    completion?()
                }
                
                switch result {
                case .Failure(_, let error):
                    self?.showError(error)
                case .Success(let topicListPage):
                    self?.topics = topicListPage.topics
                    self?.tableView.reloadData()
                    self?.refreshControl?.endRefreshing()
                    self?.addLoadMoreDataFooter()
                    if topicListPage.isLastPage {
                        self?.tableView.footer.endRefreshingWithNoMoreData()
                    }
                }
            }
    
        }
    }
    
    func loadMoreData() {
        page += 1
        if let slug = nodeSlug where mode == .Node {
            TopicSerivce.getList(nodeSlug: slug, page: page) { [weak self] (result) in
                switch result {
                case .Failure(_, let error):
                    self?.showError(error)
                case .Success(let nodePage):
                    if let name = nodePage.nodeName {
                        self?.navigationItem.title = name
                    }
                    self?.topics += nodePage.topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if nodePage.currentPage == nodePage.totalPage {
                        self?.tableView.footer.endRefreshingWithNoMoreData()
                    }
                }
            }
        } else if mode == .Favorite {
            // My favorites
            TopicSerivce.favoriteTopics(page) { [weak self] (result) in
                switch result {
                case .Failure(_, _):
                    return
                case .Success(let topicListPage):
                    self?.topics += topicListPage.topics
                    self?.tableView.reloadData()
                    self?.addLoadMoreDataFooter()
                    if topicListPage.isLastPage {
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
        showTopic2(topics[indexPath.row])
    }
    
    func showTopic2(topic: Topic) {
        if let topicVC = storyboard?.instantiateViewControllerWithIdentifier("topicVC") as? TopicViewController {
            if topic.isNew == false {
                topicVC.topicID = topic.id
            } else {
                topicVC.mode = .NewTopic
                topicVC.topic = topic
            }
            navigationController?.pushViewController(topicVC, animated: true)
        }
    }
    
    func showTopic(topic: Topic) {
        performSegueWithIdentifier("showTopicVC", sender: topic)
    }
    
    // MARK: Scroll to top
    func scrollToTopAndRefresh() {
        tableView.setContentOffset(CGPoint(x: 0, y: -refreshControl!.frame.size.height), animated: true)
        refreshControl?.beginRefreshing()
        loadData { [weak self] in
            self?.tableView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    // MARK: Segue
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
